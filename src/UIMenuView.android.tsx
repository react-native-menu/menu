import {
	codegenNativeCommands,
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

type RefT = React.ElementRef<typeof NativeMenuComponent>;

const Commands = codegenNativeCommands<{
	show: (viewRef: RefT) => void;
}>({
	supportedCommands: ["show"],
});

const MenuComponent = forwardRef<MenuComponentRef, NativeMenuComponentProps>(
	(props, ref) => {
		const nativeRef = useRef(null);

		useImperativeHandle(
			ref,
			() => ({
				show: () => {
					if (nativeRef.current) {
						// biome-ignore lint/suspicious/noExplicitAny: React Native runtime flags like nativeFabricUIManager are not in TypeScript types. Using `any` here is intentional and safe.
						const isFabric = !!(global as any).nativeFabricUIManager;

						if (isFabric) {
							Commands.show(nativeRef.current);
						} else {
							const node = findNodeHandle(nativeRef.current);
							const command =
								UIManager.getViewManagerConfig("MenuView").Commands.show;

							// The command arguments must be an array, even an empty one:
							// `undefined` reaches native code as null, and the New
							// Architecture rejects it with "expected Array, got a null".
							UIManager.dispatchViewManagerCommand(node, command, []);
						}
					}
				},
			}),
			[],
		);

		return <NativeMenuComponent {...props} ref={nativeRef} />;
	},
);

export default MenuComponent;
