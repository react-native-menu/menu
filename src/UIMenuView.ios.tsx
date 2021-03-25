import { HostComponent, requireNativeComponent } from 'react-native';
import type { NativeMenuComponentProps } from './types';

const MenuComponent = requireNativeComponent(
  'RCTUIMenu'
) as HostComponent<NativeMenuComponentProps>;

export default MenuComponent;
