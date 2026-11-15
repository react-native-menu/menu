#ifdef RCT_NEW_ARCH_ENABLED
#if __has_include(<react_native_menu/react_native_menu-Swift.h>)
#import <react_native_menu/react_native_menu-Swift.h>
#else
#import <react_native_menu-Swift.h>
#endif
#import "MenuView.h"

#import <react/renderer/components/RNMenuViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMenuViewSpec/EventEmitters.h>
#import <react/renderer/components/RNMenuViewSpec/Props.h>
#import <react/renderer/components/RNMenuViewSpec/RCTComponentViewHelpers.h>
#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface MenuView () <RCTMenuViewViewProtocol, UIContextMenuInteractionDelegate>

@end

@implementation MenuView {
    UIView <FabricViewImplementationProtocol> * _view;
    // Set while the menu opens on a long press: the context menu interaction lives on this view
    // instead of the button, see setOpensOnLongPress:
    id<UIInteraction> _longPressInteraction;
    NSString *_themeVariant;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<MenuViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const MenuViewProps>();
        _props = defaultProps;

        if (@available(iOS 14.0, *)) {
            _view = [[FabricMenuViewImplementation alloc] init];
        } else {
            _view = [[FabricActionSheetView alloc] init];
        }
        _view.onPressAction = ^(NSString *eventString) {
            [self onPressAction:eventString];
        };

        _view.onOpenMenu = ^{
            [self onOpenMenu];
        };

        _view.onCloseMenu = ^{
            [self onCloseMenu];
        };
        self.contentView = _view;
    }

  return self;
}

- (std::shared_ptr<const MenuViewEventEmitter>)getEventEmitter
{
    if (!self->_eventEmitter) {
        return nullptr;
    }

    assert(std::dynamic_pointer_cast<MenuViewEventEmitter const>(self->_eventEmitter));
    return std::static_pointer_cast<MenuViewEventEmitter const>(self->_eventEmitter);
}

- (void)onPressAction:(NSString * _Nonnull)eventString {
    // If screen is already unmounted then there will be no event emitter
    const auto eventEmitter = [self getEventEmitter];
    if (eventEmitter != nullptr) {

        eventEmitter->onPressAction(MenuViewEventEmitter::OnPressAction{
            .event = [eventString UTF8String]
        });
    }
}

- (void)onCloseMenu {
    // If screen is already unmounted then there will be no event emitter
    const auto eventEmitter = [self getEventEmitter];
    if (eventEmitter != nullptr) {
        eventEmitter->onCloseMenu({});
    }
}

- (void)onOpenMenu {
    // If screen is already unmounted then there will be no event emitter
    const auto eventEmitter = [self getEventEmitter];
    if (eventEmitter != nullptr) {
        eventEmitter->onOpenMenu({});
    }
}

/**
 Responsible for iterating through the C++ vector<struct> and convert each struct element to NSDictionary, then return it all in an NSArray
 */
- (NSMutableArray<NSDictionary *> *) convertActionsToObjC: (std::vector<MenuViewActionsStruct>) actions {
    if (actions.size() == 0) {
        return @[];
    }
    NSMutableArray<NSDictionary *> *actionsArray = [NSMutableArray arrayWithCapacity:actions.size()];
    for (const MenuViewActionsStruct &action : actions) {
        // first convert the subactions if they exist
        NSMutableArray<NSDictionary *> *subactionsArray = [NSMutableArray arrayWithCapacity:actions.size()];
        if (action.subactions.size() > 0) {
            for (const MenuViewActionsSubactionsStruct &subaction : action.subactions) {
                NSDictionary *subactionDict = @{
                    @"id": [NSString stringWithUTF8String:subaction.id.c_str()],
                    @"title": [NSString stringWithUTF8String:subaction.title.c_str()],
                    @"titleColor": @(subaction.titleColor),
                    @"subtitle": [NSString stringWithUTF8String:subaction.subtitle.c_str()],
                    @"state": [NSString stringWithUTF8String:subaction.state.c_str()],
                    @"image": [NSString stringWithUTF8String:subaction.image.c_str()],
                    @"imageColor": @(subaction.imageColor),
                    @"displayInline": @(subaction.displayInline),
                    @"attributes": @{
                        @"destructive": @(subaction.attributes.destructive),
                        @"disabled": @(subaction.attributes.disabled),
                        @"hidden": @(subaction.attributes.hidden),
                    },
                };
                [subactionsArray addObject:subactionDict];
            }
        }

        // then convert the full actions object
        NSDictionary *actionDict = @{
            @"id": [NSString stringWithUTF8String:action.id.c_str()],
            @"title": [NSString stringWithUTF8String:action.title.c_str()],
            @"titleColor": @(action.titleColor),
            @"subtitle": [NSString stringWithUTF8String:action.subtitle.c_str()],
            @"state": [NSString stringWithUTF8String:action.state.c_str()],
            @"image": [NSString stringWithUTF8String:action.image.c_str()],
            @"imageColor": @(action.imageColor),
            @"displayInline": @(action.displayInline),
            @"preferredElementSize": [NSString stringWithUTF8String:action.preferredElementSize.c_str()],
            @"attributes": @{
                @"destructive": @(action.attributes.destructive),
                @"disabled": @(action.attributes.disabled),
                @"hidden": @(action.attributes.hidden),
            },
            @"subactions": subactionsArray,
        };

        [actionsArray addObject:actionDict];
    }
    return actionsArray;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<MenuViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<MenuViewProps const>(props);


    if (oldViewProps.actionsHash != newViewProps.actionsHash) {
        _view.actions = [self convertActionsToObjC: newViewProps.actions];
    }

    if (oldViewProps.title != newViewProps.title) {
        _view.title = [NSString stringWithUTF8String:newViewProps.title.c_str()];
    }

    if (oldViewProps.themeVariant != newViewProps.themeVariant) {
        _themeVariant = [NSString stringWithUTF8String:newViewProps.themeVariant.c_str()];
        _view.themeVariant = _themeVariant;
        [self applyLongPressThemeVariant];
    }

    if (oldViewProps.shouldOpenOnLongPress != newViewProps.shouldOpenOnLongPress) {
        _view.shouldOpenOnLongPress = newViewProps.shouldOpenOnLongPress;
        [self setOpensOnLongPress:newViewProps.shouldOpenOnLongPress];
    }

    if (oldViewProps.hitSlop.top != newViewProps.hitSlop.top ||
        oldViewProps.hitSlop.bottom != newViewProps.hitSlop.bottom ||
        oldViewProps.hitSlop.left != newViewProps.hitSlop.left ||
        oldViewProps.hitSlop.right != newViewProps.hitSlop.right) {
        _view.hitSlop = UIEdgeInsetsMake(
            newViewProps.hitSlop.top,
            newViewProps.hitSlop.left,
            newViewProps.hitSlop.bottom,
            newViewProps.hitSlop.right
        );
    }

    [super updateProps:props oldProps:oldProps];
}

#pragma mark - Opening on a long press

// The button is this view's contentView, which React Native keeps above the children, so it takes
// every touch: with the menu opening on a long press, a child never received a tap, and VoiceOver
// read the whole view as one element (the view takes isAccessibilityElement from its contentView).
// In that mode the context menu interaction lives on this view instead and the button steps out of
// touches and accessibility: a tap reaches the child under the finger, a long press opens the
// button's menu, and VoiceOver reaches each child. A menu that opens on a tap is unchanged.
//
// This runs only when shouldOpenOnLongPress changes, so it relies on prepareForRecycle keeping
// _props, as the button's own showsMenuAsPrimaryAction already does: if a recycled view were reset
// to default props while still in this mode, a reused tap-to-open menu would stop opening.
- (void)setOpensOnLongPress:(BOOL)longPress
{
    if (longPress == (_longPressInteraction != nil) || ![_view isKindOfClass:[UIControl class]]) {
        return;
    }
    if (@available(iOS 14.0, *)) {
        if (longPress) {
            _longPressInteraction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
            [self addInteraction:_longPressInteraction];
        } else {
            [self removeInteraction:_longPressInteraction];
            _longPressInteraction = nil;
        }
        _view.userInteractionEnabled = !longPress;
        _view.isAccessibilityElement = !longPress;
        _view.accessibilityElementsHidden = longPress;
        [self applyLongPressThemeVariant];
    }
}

// The button applies themeVariant to its own menu. In long press mode the menu is presented from
// this view, so the variant goes here, as it does on the old architecture, where the button is the
// view that holds the children.
- (void)applyLongPressThemeVariant
{
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle style = UIUserInterfaceStyleUnspecified;
        if (_longPressInteraction != nil && [_themeVariant isEqualToString:@"dark"]) {
            style = UIUserInterfaceStyleDark;
        } else if (_longPressInteraction != nil && [_themeVariant isEqualToString:@"light"]) {
            style = UIUserInterfaceStyleLight;
        }
        self.overrideUserInterfaceStyle = style;
    }
}

// The menu, its title and the open and close events stay the button's own
- (UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                        configurationForMenuAtLocation:(CGPoint)location API_AVAILABLE(ios(14.0))
{
    return [(id<UIContextMenuInteractionDelegate>)_view contextMenuInteraction:interaction
                                                configurationForMenuAtLocation:location];
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction
       willEndForConfiguration:(UIContextMenuConfiguration *)configuration
                      animator:(id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(14.0))
{
    [(id<UIContextMenuInteractionDelegate>)_view contextMenuInteraction:interaction
                                                willEndForConfiguration:configuration
                                                               animator:animator];
}

// The preview is this view as it is drawn. One taken off screen while its menu is up just fades.
- (UITargetedPreview *)longPressPreview API_AVAILABLE(ios(14.0))
{
    return self.window != nil ? [[UITargetedPreview alloc] initWithView:self] : nil;
}

- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                                configuration:(UIContextMenuConfiguration *)configuration
        highlightPreviewForItemWithIdentifier:(id<NSCopying>)identifier API_AVAILABLE(ios(16.0))
{
    return [self longPressPreview];
}

- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
                                configuration:(UIContextMenuConfiguration *)configuration
        dismissalPreviewForItemWithIdentifier:(id<NSCopying>)identifier API_AVAILABLE(ios(16.0))
{
    return [self longPressPreview];
}

// The same preview before iOS 16, which asks these instead
- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
    previewForHighlightingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(14.0))
{
    return [self longPressPreview];
}

- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction
    previewForDismissingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(14.0))
{
    return [self longPressPreview];
}

Class<RCTComponentViewProtocol> MenuViewCls(void)
{
    return MenuView.class;
}

@end
#endif
