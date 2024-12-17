import UIKit
@available(iOS 14.0, *)
@objc(LegacyMenuViewImplementation)
public class LegacyMenuViewImplementation: MenuViewImplementation {
    @objc var onPressAction: RCTDirectEventBlock?
    @objc var onCloseMenu: RCTDirectEventBlock?
    @objc var onOpenMenu: RCTDirectEventBlock?
    
    @objc override func sendButtonAction(_ action: UIAction) {
        if let onPress = onPressAction {
            onPress(["event":action.identifier.rawValue])
        }
    }

    @objc override func sendMenuClose() {
        if let onCloseMenu = onCloseMenu {
            onCloseMenu([:])
        }
    }

    @objc override func sendMenuOpen() {
        if let onOpenMenu = onOpenMenu {
            onOpenMenu([:])
        }
    }

}
