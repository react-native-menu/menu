import type {
  DirectEventHandler,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';
import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
/*
  Caution, those below are not just typescript types.
  Codegen is using them to create the corresponding C++ data types.

  Codegen doesn't play very well with reusing the same type within a type,
  OR with extending types in an interface, so for now we'll just keep some duplicate
  types here, to avoid issues while `pod install` takes place.
*/
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
  };
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
  attributes?: {
    destructive?: boolean;
    disabled?: boolean;
    hidden?: boolean;
  };
  subactions?: Array<SubAction>;
};
export interface NativeProps extends ViewProps {
  onPressAction?: DirectEventHandler<{ event: string }>;
  actions: Array<MenuAction>;
  actionsHash: string; // just a workaround to make sure we don't have to manually compare MenuActions manually in C++ (since it's a struct and that's a pain)
  title?: string;
}

export default codegenNativeComponent<NativeProps>(
  'MenuView'
) as HostComponent<NativeProps>;
