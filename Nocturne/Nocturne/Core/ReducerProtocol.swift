import Foundation

protocol ReducerProtocol {
    associatedtype State: Sendable
    associatedtype Action: Sendable
    associatedtype Dependencies: Sendable

    static func reduce(
        state: inout State,
        action: Action,
        dependencies: Dependencies
    ) -> Effect<Action>
}
