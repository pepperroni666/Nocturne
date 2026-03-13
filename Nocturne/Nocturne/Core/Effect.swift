import Foundation

enum Effect<Action: Sendable>: Sendable {
    case none
    case task(id: EffectID? = nil, operation: @Sendable () async -> Action?)
    case stream(id: EffectID? = nil, operation: @Sendable (@escaping @Sendable (Action) async -> Void) async -> Void)
    case merge([Self])
    case cancel(EffectID)

    static func run(
        id: EffectID? = nil,
        _ operation: @escaping @Sendable () async -> Action?
    ) -> Self {
        .task(id: id, operation: operation)
    }

    static func fireAndForget(
        id: EffectID? = nil,
        _ operation: @escaping @Sendable () async -> Void
    ) -> Self {
        .task(id: id) {
            await operation()
            return nil
        }
    }

    static func merge(_ effects: Self...) -> Self {
        .merge(effects.flatMap { if case let .merge(inner) = $0 { return inner } else { return [$0] } })
    }
}
