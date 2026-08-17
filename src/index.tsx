import { forwardRef, useMemo } from "react";
import { processColor } from "react-native";

import UIMenuView from "./UIMenuView";
import type {
	MenuComponentProps,
	MenuAction,
	ProcessedMenuAction,
	NativeActionEvent,
	MenuComponentRef,
} from "./types";
import { objectHash } from "./utils";

function processAction(action: MenuAction): ProcessedMenuAction {
	return {
		...action,
		imageColor: processColor(action.imageColor),
		titleColor: processColor(action.titleColor),
		subactions: action.subactions?.map((subAction) => processAction(subAction)),
	};
}

const defaultHitslop = { top: 0, left: 0, bottom: 0, right: 0 };

// Sentinel action id the native side emits through onPressAction on a plain
// tap of the anchor (only when shouldOpenOnLongPress is set). The JS layer
// translates it into the public `onPress` callback so an anchor can be both
// tapped and long-pressed.
const ON_PRESS_EVENT = "rnmenu:onPress";

const MenuView = forwardRef<MenuComponentRef, MenuComponentProps>(
	({ actions, hitSlop = defaultHitslop, onPress, onPressAction, ...props }, ref) => {
		const processedActions = actions.map<ProcessedMenuAction>((action) =>
			processAction(action),
		);
		const hash = useMemo(() => {
			return objectHash(processedActions);
		}, [processedActions]);

		return (
			<UIMenuView
				{...props}
				hitSlop={hitSlop}
				actions={processedActions}
				actionsHash={hash}
				onPressAction={(event) => {
					if (event.nativeEvent.event === ON_PRESS_EVENT) {
						onPress?.();
						return;
					}
					onPressAction?.(event);
				}}
				ref={ref}
			/>
		);
	},
);

export { MenuView };
export type {
	MenuComponentProps,
	MenuComponentRef,
	MenuAction,
	NativeActionEvent,
};
