import UIKit
@available(iOS 14.0, *)
@objc(LegacyMenuViewImplementation)
public class LegacyMenuViewImplementation: MenuViewImplementation {
    @objc var onPressAction: RCTDirectEventBlock?
    
    @objc override func sendButtonAction(_ action: UIAction) {
        if let onPress = onPressAction {
            onPress(["event":action.identifier.rawValue])
        }
    }

}
