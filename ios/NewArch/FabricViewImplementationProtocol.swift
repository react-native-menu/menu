import Foundation
@objc public protocol FabricViewImplementationProtocol {
    var actions: [NSDictionary]? { get set }
    var title: NSString? { get set }
    var themeVariant: NSString? { get set }
    var shouldOpenOnLongPress: Bool { get set }
    @objc optional var hitSlop: UIEdgeInsets { get set }
    var onPressAction: ((String) -> Void)? { get set }
    var onCloseMenu: (() -> Void)? { get set }
    var onOpenMenu: (() -> Void)? { get set }
}
