// Private SwiftPM declarations for the Fabric adapter. Xcode's generated
// react_native_menu-Swift.h is exposed through a module map, but C++ module
// imports are disabled and its directory is not an ObjC++ header search path.
// Keep this narrow interface in sync with that header and ios/NewArch/*.swift.
// The Swift classes use explicit @objc names, so these declarations resolve to
// their implementations without a Swift -> ObjC target dependency.
#pragma once
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
__attribute__((objc_runtime_name("_TtP17react_native_menu32FabricViewImplementationProtocol_")))
@protocol FabricViewImplementationProtocol
@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *actions;
@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) NSString *themeVariant;
@property (nonatomic) BOOL shouldOpenOnLongPress;
@property (nonatomic, copy, nullable) void (^onPressAction)(NSString *);
@property (nonatomic, copy, nullable) void (^onCloseMenu)(void);
@property (nonatomic, copy, nullable) void (^onOpenMenu)(void);
@optional
@property (nonatomic) UIEdgeInsets hitSlop;
@end

@interface FabricMenuViewImplementation : UIButton <FabricViewImplementationProtocol>
@end
@interface FabricActionSheetView : UIView <FabricViewImplementationProtocol>
@end
NS_ASSUME_NONNULL_END
