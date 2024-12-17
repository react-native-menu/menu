@objc(FabricActionSheetView)
public class FabricActionSheetView: ActionSheetView, FabricViewImplementationProtocol {
    public var onPressAction: ((String) -> Void)?
    public var onCloseMenu: (() -> Void)?
        
    @objc override func sendButtonAction(_ action: String) {
        if let onPress = onPressAction {
            onPress(action)
        }
    }

    @objc override func sendMenuClose() {
        if let onCloseMenu = onCloseMenu {
            onCloseMenu()
        }
    }
}
