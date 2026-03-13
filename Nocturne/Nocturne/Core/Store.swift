import Foundation
import Observation

// Reference box that lets a Task's closure body compare itself against the
// tasks dictionary without a forward reference to the task variable itself.
private final class TaskRef: @unchecked Sendable {
    var value: Task<Void, Never>?
}

@MainActor
@Observable
final class Store<State: Sendable, Action: Sendable> {
    private(set) var state: State
    private let reducer: @MainActor (inout State, Action) -> Effect<Action>
    private var tasks: [EffectID: Task<Void, Never>] = [:]

    init(initial: State, reducer: @escaping @MainActor (inout State, Action) -> Effect<Action>) {
        self.state = initial
        self.reducer = reducer
    }

    convenience init<R: ReducerProtocol>(
        initial: R.State,
        reducer: R.Type,
        dependencies: R.Dependencies
    ) where State == R.State, Action == R.Action {
        self.init(initial: initial, reducer: { state, action in
            R.reduce(state: &state, action: action, dependencies: dependencies)
        })
    }

    func send(_ action: Action) {
        let effect = reducer(&state, action)
        execute(effect)
    }

    /// Cancels all in-flight named effects. Anonymous effects (id: nil) are
    /// fire-and-forget and are not tracked here.
    func cancelAll() {
        for task in tasks.values { task.cancel() }
        tasks.removeAll()
    }

    // MARK: - Private

    private func cancelTask(id: EffectID) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
    }

    private func register(id: EffectID?, _ task: Task<Void, Never>) {
        guard let id else { return }
        cancelTask(id: id)
        tasks[id] = task
    }

    /// Creates, registers, and starts a task. The body receives a `TaskRef`
    /// pre-wired to the task, enabling identity-safe cleanup.
    private func makeTask(id: EffectID?, _ body: @escaping @MainActor (TaskRef) async -> Void) {
        let ref = TaskRef()
        let task = Task { [ref] in await body(ref) }
        ref.value = task
        register(id: id, task)
    }

    private func execute(_ effect: Effect<Action>) {
        switch effect {

        case .none:
            break

        case let .task(id, operation):
            makeTask(id: id) { [weak self] ref in
                guard !Task.isCancelled else { return }
                let action = await operation()
                guard !Task.isCancelled, let action else { return }
                guard let self else { return }
                self.send(action)
                if let id, self.tasks[id] == ref.value {
                    self.tasks.removeValue(forKey: id)
                }
            }

        case let .stream(id, operation):
            makeTask(id: id) { [weak self] ref in
                // send is awaited here because operations may emit from a
                // non-@MainActor context (e.g. an audio engine actor).
                await operation { [weak self] (action: Action) in
                    guard !Task.isCancelled else { return }
                    guard let self else { return }
                    await self.send(action)
                }
                guard !Task.isCancelled, let self, let id else { return }
                if self.tasks[id] == ref.value {
                    self.tasks.removeValue(forKey: id)
                }
            }

        case let .merge(effects):
            for effect in effects { execute(effect) }

        case let .cancel(id):
            cancelTask(id: id)
        }
    }
}
