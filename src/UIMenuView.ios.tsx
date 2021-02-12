import { HostComponent, requireNativeComponent } from 'react-native';
import type { MenuComponentProps } from './types';

const MenuComponent = requireNativeComponent(
  'RCTUIMenu'
) as HostComponent<MenuComponentProps>;

export default MenuComponent;
