import { NativeModules } from 'react-native';

type MenuType = {
  multiply(a: number, b: number): Promise<number>;
};

const { Menu } = NativeModules;

export default Menu as MenuType;
