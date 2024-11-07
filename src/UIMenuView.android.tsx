import {
	findNodeHandle,
	type HostComponent,
	requireNativeComponent,
	UIManager,
} from "react-native";
import type { MenuComponentRef, NativeMenuComponentProps } from "./types";
import { forwardRef, useImperativeHandle, useRef } from "react";

const NativeMenuComponent = requireNativeComponent(
	"MenuView",
) as HostComponent<NativeMenuComponentProps>;

const MenuComponent = forwardRef<MenuComponentRef, NativeMenuComponentProps>(
	(props, ref) => {
		const nativeRef = useRef(null);

		useImperativeHandle(
			ref,
			() => ({
				show: () => {
					if (nativeRef.current) {
						const node = findNodeHandle(nativeRef.current);
						const command =
							UIManager.getViewManagerConfig("MenuView").Commands.show;

						UIManager.dispatchViewManagerCommand(node, command, undefined);
					}
				},
			}),
			[],
		);

		return <NativeMenuComponent {...props} ref={nativeRef} />;
	},
);

export default MenuComponent;
