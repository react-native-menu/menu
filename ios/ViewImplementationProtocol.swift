import Foundation
@objc public protocol ViewImplementationProtocol {
    
    var actions: [NSDictionary]? { get set }
    var title: NSString? { get set }
    var onPressAction: ((String) -> Void)? { get set }
}
