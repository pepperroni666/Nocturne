import Foundation
import Observation

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

    private func execute(_ effect: Effect<Action>) {
        switch effect {

        case .none:
            break

        case let .task(id, operation):
            let task = Task { [weak self] in
                guard let action = await operation() else { return }
                self?.send(action)
            }
            if let id {
                tasks[id]?.cancel()
                tasks[id] = task
            }

        case let .stream(id, operation):
            let task = Task { [weak self] in
                await operation { [weak self] action in
                    self?.send(action)
                }
            }
            if let id {
                tasks[id]?.cancel()
                tasks[id] = task
            }

        case let .merge(effects):
            effects.forEach { execute($0) }

        case let .cancel(id):
            tasks[id]?.cancel()
            tasks.removeValue(forKey: id)
        }
    }
}
