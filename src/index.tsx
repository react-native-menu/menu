import {
  HostComponent,
  requireNativeComponent,
  StyleProp,
  ViewStyle,
} from 'react-native';

type MenuComponentProps = {
  style?: StyleProp<ViewStyle>;
  onPressAction?: ({ nativeEvent }: any) => void;
  actions: any[];
  menuTitle?: string;
};

const MenuComponent = requireNativeComponent('RCTUIMenu') as HostComponent<
  MenuComponentProps
>;

export default MenuComponent;
