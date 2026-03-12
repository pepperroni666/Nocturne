import Foundation
import Testing
@testable import Nocturne

@Suite("Store")
@MainActor
struct StoreTests {
    enum TestAction: Sendable {
        case increment
        case decrement
        case set(Int)
        case asyncIncrement
        case noop
    }

    struct TestState: Equatable, Sendable {
        var count: Int = 0
    }

    @MainActor
    @Test("send updates state synchronously")
    func sendUpdatesState() {
        let store = Store<TestState, TestAction>(
            initial: TestState(),
            reducer: { state, action in
                switch action {
                case .increment: state.count += 1; return .none
                case .decrement: state.count -= 1; return .none
                case .set(let v): state.count = v; return .none
                case .asyncIncrement: return .run { .increment }
                case .noop: return .none
                }
            }
        )

        store.send(.increment)
        #expect(store.state.count == 1)

        store.send(.increment)
        #expect(store.state.count == 2)

        store.send(.decrement)
        #expect(store.state.count == 1)

        store.send(.set(42))
        #expect(store.state.count == 42)
    }

    @MainActor
    @Test("effect feeds back action")
    func effectFeedback() async throws {
        let store = Store<TestState, TestAction>(
            initial: TestState(),
            reducer: { state, action in
                switch action {
                case .increment: state.count += 1; return .none
                case .asyncIncrement: return .run { .increment }
                default: return .none
                }
            }
        )

        store.send(.asyncIncrement)
        // Give the async effect time to complete
        try await Task.sleep(for: .milliseconds(50))
        #expect(store.state.count == 1)
    }
}
