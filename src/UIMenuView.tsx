import * as React from 'react';
import { View } from 'react-native';
import type { MenuComponentProps } from './types';

/**
 * TODO: implement for Android and Web
 */
const MenuView: React.FC<MenuComponentProps> = ({ style, children }) => {
  return <View style={style}>{children}</View>;
};

export default MenuView;
