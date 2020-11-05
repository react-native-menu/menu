import * as React from 'react';
import { StyleProp, View, ViewStyle } from 'react-native';

type MenuComponentProps = {
  style?: StyleProp<ViewStyle>;
  onPressAction?: ({ nativeEvent }: any) => void;
  actions: any[];
  menuTitle?: string;
};

const MenuView: React.FC<MenuComponentProps> = () => {
  return <View />;
};

export default MenuView;
