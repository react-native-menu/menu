import type {
	ColorValue,
	processColor,
	StyleProp,
	ViewStyle,
} from "react-native";
import type * as React from "react";

export type NativeActionEvent = {
	nativeEvent: {
		event: string;
	};
};

export type MenuThemeVariant = "light" | "dark" | "system";

export type MenuUiKit = "auto" | "material3" | "appcompat";

type MenuAttributes = {
	/**
	 * An attribute indicating the destructive style.
	 */
	destructive?: boolean;
	/**
	 * An attribute indicating the disabled style.
	 */
	disabled?: boolean;
	/**
	 * An attribute indicating the hidden style.
	 */
	hidden?: boolean;
	/**
	 * (iOS16+ only)
	 * @platform iOS
	 * An attribute indicating that the menu should remain presented after firing.
	 */
	keepsMenuPresented?: boolean;
};

/**
 * The state of the action.
 * - off: A constant indicating the menu element is in the “off” state.
 * - on: A constant indicating the menu element is in the “on” state.
 * - mixed: A constant indicating the menu element is in the “mixed” state.
 */
type MenuState = "off" | "on" | "mixed";

export type MenuAction = {
	/**
	 * Identifier of the menu action.
	 * The value set in this id will be returned when menu is selected.
	 */
	id?: string;
	/**
	 * The action's title.
	 */
	title: string;
	/**
	 * (Android only)
	 * The action's title color.
	 * @platform Android
	 */
	titleColor?: number | ColorValue;
	/**
	 * (iOS14+ only)
	 * An elaborated title that explains the purpose of the action.
	 * @platform iOS
	 */
	subtitle?: string;
	/**
	 * The attributes indicating the style of the action.
	 */
	attributes?: MenuAttributes;
	/**
	 * (iOS14+ only)
	 * The state of the action.
	 * @platform iOS
	 */
	state?: MenuState;
	/**
	 * (Android and iOS13+ only)
	 * - The action's image.
	 * - Allows icon name included in project or system (Android) resources drawables and
	 * in SF Symbol (iOS)
	 * @example // (iOS)
	 * image="plus"
	 * @example // (Android)
	 * image="ic_menu_add"
	 * - TODO: Allow images other than those included in SF Symbol and resources drawables
	 */
	image?: string;
	/**
	 * (Android and iOS13+ only)
	 * - The action's image color.
	 */
	imageColor?: number | ColorValue;
	/**
	 * (Android and iOS14+ only)
	 * - Actions to be displayed in the sub menu
	 * - On Android it does not support nesting next sub menus in sub menu item
	 */
	subactions?: MenuAction[];
	/**
	 * Whether subactions should be inline (separated by divider) or nested (sub menu)
	 */
	displayInline?: boolean;
	/**
	 * (iOS 16+ only)
	 * The preferred size of this menu's child elements.
	 * @platform iOS
	 */
	preferredElementSize?: "small" | "medium" | "large";
};

type MenuComponentPropsBase = {
	style?: StyleProp<ViewStyle>;
	/**
	 * Callback function that will be called when selecting a menu item.
	 * It will contain id of the given action.
	 */
	onPressAction?: ({ nativeEvent }: NativeActionEvent) => void;
	/**
	 * Callback function that will be called when the menu closes.
	 */
	onCloseMenu?: () => void;
	/**
	 * Callback function that will be called when the menu opens.
	 */
	onOpenMenu?: () => void;
	/**
	 * Actions to be displayed in the menu.
	 */
	actions: MenuAction[];
	/**
	 * The title of the menu.
	 */
	title?: string;

	/**
	 * (Android API 23+)
	 * Boolean value determines whether popup menu should be anchored
	 * to right corner of parent view - default value is `false`
	 * @platform Android
	 */
	isAnchoredToRight?: boolean;
	/**
	 * Determines if menu should open after long press or on normal press
	 *
	 * @default false
	 */
	shouldOpenOnLongPress?: boolean;
	/**
	 * Overrides theme variant of menu to light mode, dark mode or system theme
	 * @default system
	 */
	themeVariant?: MenuThemeVariant;
	/**
	 * Overrides UI kit of menu to auto, material3 or appcompat
	 * @platform Android
	 * @default auto
	 */
	uiKit?: MenuUiKit;
	/**
	 * Custom OpenSpace hitSlop prop. Works like touchable hitslop.
	 * @platform iOS
	 */
	hitSlop?: {
		top: number;
		bottom: number;
		left: number;
		right: number;
	};
	/**
	 * Test ID for testing purposes
	 */
	testID?: string;
};

export type MenuComponentProps =
	React.PropsWithChildren<MenuComponentPropsBase>;

export type MenuComponentRef = {
	show: () => void;
};

export type ProcessedMenuAction = Omit<
	MenuAction,
	"imageColor" | "titleColor" | "subactions"
> & {
	imageColor: ReturnType<typeof processColor>;
	titleColor: ReturnType<typeof processColor>;
	subactions?: ProcessedMenuAction[];
};

export type NativeMenuComponentProps = {
	style?: StyleProp<ViewStyle>;
	onPressAction?: ({ nativeEvent }: NativeActionEvent) => void;
	onCloseMenu?: () => void;
	onOpenMenu?: () => void;
	actions: ProcessedMenuAction[];
	actionsHash: string;
	title?: string;
	hitSlop?: MenuComponentProps["hitSlop"];
	testID?: string;
	ref?: React.ForwardedRef<MenuComponentRef>;
};
