import Foundation

enum Effect<Action: Sendable>: Sendable {
    case none
    case task(id: UUID = UUID(), operation: @Sendable () async -> Action?)
    case stream(id: UUID = UUID(), operation: @Sendable (@escaping @MainActor (Action) -> Void) async -> Void)
    case merge([Effect<Action>])
    case cancel(UUID)

    static func run(id: UUID = UUID(), _ operation: @escaping @Sendable () async -> Action?) -> Effect {
        .task(id: id, operation: operation)
    }

    static func fireAndForget(id: UUID = UUID(), _ operation: @escaping @Sendable () async -> Void) -> Effect {
        .task(id: id, operation: {
            await operation()
            return nil
        })
    }
}
