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

@interface MenuView () <RCTMenuViewViewProtocol>

@end

@implementation MenuView {
    UIView <FabricViewImplementationProtocol> * _view;
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

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> MenuViewCls(void)
{
    return MenuView.class;
}

@end
#endif
