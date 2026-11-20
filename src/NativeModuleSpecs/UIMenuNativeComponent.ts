// biome-ignore-start lint/suspicious/noReactNativeDeepImports: this is a codegen spec file.
// React Native's codegen parses these imports directly and expects CodegenTypes and
// codegenNativeComponent on these exact paths. react-native/index.js does re-export
// codegenNativeComponent, but rewriting an import that codegen parses risks breaking native
// builds for no benefit -- see the note on this file in CLAUDE.md. Scoped to this import
// block rather than the whole file, so accidental deep imports below are still caught.
import type {
	DirectEventHandler,
	Int32,
	WithDefault
} from "react-native/Libraries/Types/CodegenTypes";
import type { HostComponent, ViewProps } from "react-native";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";
// biome-ignore-end lint/suspicious/noReactNativeDeepImports: end of the codegen import block.

/*
  Caution, those below are not just typescript types.
  Codegen is using them to create the corresponding C++ data types.

  Codegen doesn't play very well with reusing the same type within a type,
  OR with extending types in an interface, so for now we'll just keep some duplicate
  types here, to avoid issues while `pod install` takes place.
*/

type SubSubAction = {
	id?: string;
	title: string;
	titleColor?: Int32;
	subtitle?: string;
	state?: string;
	image?: string;
	imageColor?: Int32;
	displayInline?: boolean;
	attributes?: {
		destructive?: boolean;
		disabled?: boolean;
		hidden?: boolean;
		keepsMenuPresented?: boolean;
	};
};
type SubAction = {
	id?: string;
	title: string;
	titleColor?: Int32;
	subtitle?: string;
	state?: string;
	image?: string;
	imageColor?: Int32;
	displayInline?: boolean;
	attributes?: {
		destructive?: boolean;
		disabled?: boolean;
		hidden?: boolean;
		keepsMenuPresented?: boolean;
	};
	subactions?: Array<SubSubAction>;
};
type MenuAction = {
	id?: string;
	title: string;
	titleColor?: Int32;
	subtitle?: string;
	state?: string;
	image?: string;
	imageColor?: Int32;
	displayInline?: boolean;
	preferredElementSize?: WithDefault<string, 'large'>;
	attributes?: {
		destructive?: boolean;
		disabled?: boolean;
		hidden?: boolean;
		keepsMenuPresented?: boolean;
	};
	subactions?: Array<SubAction>;
};
export interface NativeProps extends ViewProps {
	onPressAction?: DirectEventHandler<{ event: string }>;
	onCloseMenu?: DirectEventHandler<{ event: string }>;
	onOpenMenu?: DirectEventHandler<{ event: string }>;
	actions: Array<MenuAction>;
	actionsHash: string; // just a workaround to make sure we don't have to manually compare MenuActions manually in C++ (since it's a struct and that's a pain)
	title?: string;
	themeVariant?: string;
	isAnchoredToRight?: boolean;
	shouldOpenOnLongPress?: boolean;
	hitSlop: {
		top: Int32;
		bottom: Int32;
		left: Int32;
		right: Int32;
	};
}

export default codegenNativeComponent<NativeProps>(
	"MenuView",
) as HostComponent<NativeProps>;
