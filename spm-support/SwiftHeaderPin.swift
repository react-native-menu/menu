// Pins the Swift API mirrored by spm-headers/react_native_menu-Swift.h.
// If this file fails to compile, update both files together.
import UIKit

// Swift cannot compile-time check explicit @objc class-name strings or the
// protocol's module-qualified mangled runtime name. No runtime checks belong here.

private let _menu_actions: ReferenceWritableKeyPath<FabricMenuViewImplementation, [NSDictionary]?> = \.actions
private let _menu_title: ReferenceWritableKeyPath<FabricMenuViewImplementation, NSString?> = \.title
private let _menu_themeVariant: ReferenceWritableKeyPath<FabricMenuViewImplementation, NSString?> = \.themeVariant
private let _menu_shouldOpenOnLongPress: ReferenceWritableKeyPath<FabricMenuViewImplementation, Bool> = \.shouldOpenOnLongPress
private let _menu_onPressAction: ReferenceWritableKeyPath<FabricMenuViewImplementation, ((String) -> Void)?> = \.onPressAction
private let _menu_onCloseMenu: ReferenceWritableKeyPath<FabricMenuViewImplementation, (() -> Void)?> = \.onCloseMenu
private let _menu_onOpenMenu: ReferenceWritableKeyPath<FabricMenuViewImplementation, (() -> Void)?> = \.onOpenMenu
private let _menu_hitSlop: ReferenceWritableKeyPath<FabricMenuViewImplementation, UIEdgeInsets> = \.hitSlop

private let _menu_selectors: [Selector] = [
    #selector(getter: FabricMenuViewImplementation.actions),
    #selector(setter: FabricMenuViewImplementation.actions),
    #selector(getter: FabricMenuViewImplementation.title),
    #selector(setter: FabricMenuViewImplementation.title),
    #selector(getter: FabricMenuViewImplementation.themeVariant),
    #selector(setter: FabricMenuViewImplementation.themeVariant),
    #selector(getter: FabricMenuViewImplementation.shouldOpenOnLongPress),
    #selector(setter: FabricMenuViewImplementation.shouldOpenOnLongPress),
    #selector(getter: FabricMenuViewImplementation.onPressAction),
    #selector(setter: FabricMenuViewImplementation.onPressAction),
    #selector(getter: FabricMenuViewImplementation.onCloseMenu),
    #selector(setter: FabricMenuViewImplementation.onCloseMenu),
    #selector(getter: FabricMenuViewImplementation.onOpenMenu),
    #selector(setter: FabricMenuViewImplementation.onOpenMenu),
    #selector(getter: FabricMenuViewImplementation.hitSlop),
    #selector(setter: FabricMenuViewImplementation.hitSlop),
]

private let _sheet_actions: ReferenceWritableKeyPath<FabricActionSheetView, [NSDictionary]?> = \.actions
private let _sheet_title: ReferenceWritableKeyPath<FabricActionSheetView, NSString?> = \.title
private let _sheet_themeVariant: ReferenceWritableKeyPath<FabricActionSheetView, NSString?> = \.themeVariant
private let _sheet_shouldOpenOnLongPress: ReferenceWritableKeyPath<FabricActionSheetView, Bool> = \.shouldOpenOnLongPress
private let _sheet_onPressAction: ReferenceWritableKeyPath<FabricActionSheetView, ((String) -> Void)?> = \.onPressAction
private let _sheet_onCloseMenu: ReferenceWritableKeyPath<FabricActionSheetView, (() -> Void)?> = \.onCloseMenu
private let _sheet_onOpenMenu: ReferenceWritableKeyPath<FabricActionSheetView, (() -> Void)?> = \.onOpenMenu

private let _sheet_selectors: [Selector] = [
    #selector(getter: FabricActionSheetView.actions),
    #selector(setter: FabricActionSheetView.actions),
    #selector(getter: FabricActionSheetView.title),
    #selector(setter: FabricActionSheetView.title),
    #selector(getter: FabricActionSheetView.themeVariant),
    #selector(setter: FabricActionSheetView.themeVariant),
    #selector(getter: FabricActionSheetView.shouldOpenOnLongPress),
    #selector(setter: FabricActionSheetView.shouldOpenOnLongPress),
    #selector(getter: FabricActionSheetView.onPressAction),
    #selector(setter: FabricActionSheetView.onPressAction),
    #selector(getter: FabricActionSheetView.onCloseMenu),
    #selector(setter: FabricActionSheetView.onCloseMenu),
    #selector(getter: FabricActionSheetView.onOpenMenu),
    #selector(setter: FabricActionSheetView.onOpenMenu),
]

private let _protocol_hitSlopSelectors: [Selector] = [
    #selector(getter: FabricViewImplementationProtocol.hitSlop),
    #selector(setter: FabricViewImplementationProtocol.hitSlop),
]
