import Foundation

enum Effect<Action: Sendable>: Sendable {
    case none
    case task(id: EffectID? = nil, operation: @Sendable () async -> Action?)
    case stream(id: EffectID? = nil, operation: @Sendable (@escaping @MainActor @Sendable (Action) -> Void) async -> Void)
    case merge([Effect<Action>])
    case cancel(EffectID)

    static func run(
        id: EffectID? = nil,
        _ operation: @escaping @Sendable () async -> Action?
    ) -> Effect {
        .task(id: id, operation: operation)
    }

    static func fireAndForget(
        id: EffectID? = nil,
        _ operation: @escaping @Sendable () async -> Void
    ) -> Effect {
        .task(id: id) {
            await operation()
            return nil
        }
    }

    static func merge(_ effects: Effect...) -> Effect {
        .merge(effects)
    }
}
