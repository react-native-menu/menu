
@objc(FabricActionSheetView)
public class FabricActionSheetView: ActionSheetView, FabricViewImplementationProtocol {
    public var onPressAction: ((String) -> Void)?
        
    @objc override func sendButtonAction(_ action: String) {
        if let onPress = onPressAction {
            onPress(action)
        }
    }
}
