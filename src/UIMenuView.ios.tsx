import type * as React from "react";
import { forwardRef, useImperativeHandle } from "react";
import UIMenuNativeComponent from "./NativeModuleSpecs/UIMenuNativeComponent";
import type { MenuComponentRef } from "./types";

type NativeProps = Omit<
	React.ComponentProps<typeof UIMenuNativeComponent>,
	"ref"
>;

/**
 * `show()` opens the menu from code on Android. iOS has no public API to
 * present a UIMenu from code, so here it does nothing. It is still defined, so
 * shared code that calls `ref.current?.show()` doesn't throw
 * `show is not a function` on iOS.
 */
const MenuComponent = forwardRef<MenuComponentRef, NativeProps>(
	(props, ref) => {
		useImperativeHandle(
			ref,
			() => ({
				show: () => {
					if (__DEV__) {
						console.warn(
							"MenuView: show() is only supported on Android and does nothing on iOS.",
						);
					}
				},
			}),
			[],
		);

		return <UIMenuNativeComponent {...props} />;
	},
);

export default MenuComponent;
