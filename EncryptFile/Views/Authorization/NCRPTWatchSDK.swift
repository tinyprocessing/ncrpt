import Combine
import Foundation
import SwiftUI
import UIKit

class NCRPTWatchSDK: NSObject, ObservableObject, Identifiable {
    static let shared = NCRPTWatchSDK()
    @Published var ui: UI = .loading
    @Published var authorization = NCRPTAuthSDK.shared
    @Published var authorizationStatus = false

    @Published var needBlur = false

    var visualEffectView = UIVisualEffectView()

    var callback: ((_ success: Bool) -> Void)?

    var window: UIWindow? = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

    func isAuthorized() -> Bool {
        return authorizationStatus
    }

    enum UI {
        case loading
        case cache
        case pin
        case pinCreate
        case auth
        case ready
        case error
    }

    func setupSecureView() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: OperationQueue.main
        ) { _ in
            withAnimation {
                self.needBlur = false
            }
        }
        NotificationCenter.default
            .addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { _ in
                withAnimation {
                    self.needBlur = false
                }
            }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: OperationQueue.main
        ) { [self] _ in
            if self.ui == .pinCreate {
                self.ui = .auth
                Settings.shared.logout()
            }
            withAnimation {
                needBlur = true
            }
        }
    }

    /// Запуск SDK
    /// - Parameter completion:
    public func start(completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        authorizationStatus = false
    }
}
