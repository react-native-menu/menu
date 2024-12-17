@objc(FabricActionSheetView)
public class FabricActionSheetView: ActionSheetView, FabricViewImplementationProtocol {
    public var onPressAction: ((String) -> Void)?
    public var onCloseMenu: (() -> Void)?
    public var onOpenMenu: (() -> Void)?
    
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
    @objc override func sendMenuOpen() {
        if let onOpenMenu = onOpenMenu {
            onOpenMenu()
        }
    }
}
