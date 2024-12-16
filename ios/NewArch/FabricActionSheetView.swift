@objc(FabricActionSheetView)
public class FabricActionSheetView: ActionSheetView, FabricViewImplementationProtocol {
    public var onPressAction: ((String) -> Void)?
    public var onMenuClose: (() -> Void)?
        
    @objc override func sendButtonAction(_ action: String) {
        if let onPress = onPressAction {
            onPress(action)
        }
    }

    @objc override func sendMenuClose() {
        if let onMenuClose = onMenuClose {
            onMenuClose()
        }
    }
}
