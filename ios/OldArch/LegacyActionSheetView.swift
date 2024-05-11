
@objc(LegacyActionSheetView)
public class LegacyActionSheetView: ActionSheetView {
    @objc var onPressAction: RCTDirectEventBlock?
    
    @objc override func sendButtonAction(_ action: String) {
        if let onPress = onPressAction {
            onPress(["event":action])
        }
    }
}
