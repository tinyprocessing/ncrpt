import Foundation
import UIKit

public protocol ScreenshotInvincibleContainerProtocol: UIView {
    func eraseOldAndAddnewContent(_ newContent: UIView)
    func setupContanerAsHideContentInScreenshots()
    func setupContanerAsDisplayContentInScreenshots()
}
