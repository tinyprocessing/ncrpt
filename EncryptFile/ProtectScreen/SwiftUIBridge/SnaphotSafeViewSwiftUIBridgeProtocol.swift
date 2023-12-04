#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13, *)
protocol SnaphotSafeViewSwiftUIBridgeProtocol {
    associatedtype ProtectedView: View

    func hiddenFromSystemSnaphot() -> ProtectedView
}
#endif
