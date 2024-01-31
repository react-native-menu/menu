import Foundation
@objc public protocol ViewImplementationProtocol {
#if RCT_NEW_ARCH_ENABLED
    var actions: [NSDictionary]? { get set }
    var title: NSString? { get set }
    var onPressAction: ((String) -> Void)? { get set }
#endif
}
