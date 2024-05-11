import * as React from 'react';
import { View } from 'react-native';
import type { NativeMenuComponentProps } from './types';

/**
 * TODO: implement for Web
 */
const MenuView: React.FC<React.PropsWithChildren<NativeMenuComponentProps>> = ({
  style,
  children,
}) => {
  return <View style={style}>{children}</View>;
};

export default MenuView;
