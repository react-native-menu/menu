@objc(RCTUIMenu)
class RCTUIMenuManager: RCTViewManager {
    
//    @objc var item: json?;
    @objc var onPressMenuItem: RCTBubblingEventBlock?;
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func view() -> UIView! {
        if #available(iOS 14.0, *) {    
            return MenuView();
        } else {
            return ActionSheetView();
        }
    }
}

