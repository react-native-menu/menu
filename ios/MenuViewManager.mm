#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"
#import "MenuView.h"

@interface MenuViewManager : RCTViewManager
@end

@implementation MenuViewManager

RCT_EXPORT_MODULE(MenuView)

- (UIView *)view
{
    return [[MenuView alloc] init];
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
RCT_EXPORT_VIEW_PROPERTY(actionsHash, NSString);

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

@end
