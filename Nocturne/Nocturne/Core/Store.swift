import Foundation
import Observation

@MainActor
@Observable
final class Store<State: Equatable, Action: Sendable> {
    private(set) var state: State
    private let reducer: @MainActor (inout State, Action) -> Effect<Action>
    private var effectTasks: [UUID: Task<Void, Never>] = [:]

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

    private func execute(_ effect: Effect<Action>) {
        switch effect {
        case .none:
            break

        case let .task(id, operation):
            let task = Task { [weak self] in
                guard let action = await operation() else { return }
                self?.send(action)
            }
            effectTasks[id]?.cancel()
            effectTasks[id] = task

        case let .stream(id, operation):
            let task = Task { [weak self] in
                await operation { action in
                    self?.send(action)
                }
            }
            effectTasks[id]?.cancel()
            effectTasks[id] = task

        case let .merge(effects):
            for effect in effects {
                execute(effect)
            }

        case let .cancel(id):
            effectTasks[id]?.cancel()
            effectTasks.removeValue(forKey: id)
        }
    }
}
