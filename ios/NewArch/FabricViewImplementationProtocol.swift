import Foundation
@objc public protocol FabricViewImplementationProtocol {
    var actions: [NSDictionary]? { get set }
    var title: NSString? { get set }
    var onPressAction: ((String) -> Void)? { get set }
}
