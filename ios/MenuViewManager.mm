#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"

#ifdef RCT_NEW_ARCH_ENABLED
// NEW ARCH
#import "MenuView.h"
#else
// OLD ARCH
#if __has_include(<react_native_menu/react_native_menu-Swift.h>)
#import <react_native_menu/react_native_menu-Swift.h>
#else
#import <react_native_menu-Swift.h>
#endif

#endif

@interface MenuViewManager : RCTViewManager
@end

@implementation MenuViewManager

RCT_EXPORT_MODULE(MenuView)

- (UIView *)view
{
#ifdef RCT_NEW_ARCH_ENABLED
    // NEW ARCH
    return [[MenuView alloc] init];
#else
    // OLD ARCH
    if (@available(iOS 14.0, *)) {
        return [[LegacyMenuViewImplementation alloc] init];
    } else {
        return [[LegacyActionSheetView alloc] init];
    }
#endif /* RCT_NEW_ARCH_ENABLED */
}

/**
 * title: Short description to be displayed above the menu.
 */
RCT_EXPORT_VIEW_PROPERTY(title, NSString);
/**
 * actions: Array of actions that are included in the menu
 */
RCT_EXPORT_VIEW_PROPERTY(actions, NSArray);
/**
 * actionsHash: String hash that changes any time the actions change (so that we don't have to deeply compare values)
 */
#ifdef RCT_NEW_ARCH_ENABLED
    // NEW ARCH
RCT_EXPORT_VIEW_PROPERTY(actionsHash, NSString);
#endif

/**
 * onPressAction: callback to be called once user selects an action
 */
RCT_EXPORT_VIEW_PROPERTY(onPressAction, RCTDirectEventBlock);
/**
 * shouldOpenOnLongPress: determines whether menu should be opened after long press or normal press
 */
RCT_EXPORT_VIEW_PROPERTY(shouldOpenOnLongPress, BOOL)
/**
 * themeVariant: determines whether menu should use dark theme, light theme or system theme
 */
RCT_EXPORT_VIEW_PROPERTY(themeVariant, NSString)

/**
 * hitSlop: The same as hitSlop in React Native
*/
RCT_EXPORT_VIEW_PROPERTY(hitSlop, UIEdgeInsets)

@end
