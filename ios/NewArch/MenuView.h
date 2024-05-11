// This guard prevent this file to be compiled in the old architecture.

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef MenuViewNativeComponent_h
#define MenuViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@protocol FabricViewImplementationProtocol;
@interface MenuView : RCTViewComponentView
@end

NS_ASSUME_NONNULL_END

#endif /* MenuViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
