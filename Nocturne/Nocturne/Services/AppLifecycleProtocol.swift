import Foundation
import UIKit

enum AppLifecycleEvent: Sendable {
    case didBecomeActive
    case willResignActive
    case didEnterBackground
}

protocol AppLifecycleProtocol: Sendable {
    var events: AsyncStream<AppLifecycleEvent> { get }
}

final class UIKitAppLifecycle: AppLifecycleProtocol, @unchecked Sendable {
    let events: AsyncStream<AppLifecycleEvent>

    init() {
        events = AsyncStream { continuation in
            let center = NotificationCenter.default

            let activeObserver = center.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil, queue: .main
            ) { _ in continuation.yield(.didBecomeActive) }

            let resignObserver = center.addObserver(
                forName: UIApplication.willResignActiveNotification,
                object: nil, queue: .main
            ) { _ in continuation.yield(.willResignActive) }

            let backgroundObserver = center.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil, queue: .main
            ) { _ in continuation.yield(.didEnterBackground) }

            continuation.onTermination = { _ in
                center.removeObserver(activeObserver)
                center.removeObserver(resignObserver)
                center.removeObserver(backgroundObserver)
            }
        }
    }
}
