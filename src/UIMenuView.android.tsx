import { HostComponent, requireNativeComponent } from 'react-native';
import type { MenuComponentProps } from './types';

const MenuComponent = requireNativeComponent(
  'MenuView'
) as HostComponent<MenuComponentProps>;

export default MenuComponent;
