import React from 'react';
import { processColor } from 'react-native';

import UIMenuView from './UIMenuView';
import type {
  MenuComponentProps,
  MenuAction,
  ProcessedMenuAction,
} from './types';

const MenuView: React.FC<MenuComponentProps> = ({ actions, ...props }) => {
  const processedActions = actions.map<ProcessedMenuAction>((action) => ({
    ...action,
    imageColor: processColor(action.imageColor),
    titleColor: processColor(action.titleColor),
  }));
  return <UIMenuView {...props} actions={processedActions} />;
};

export { MenuView };
export type { MenuComponentProps, MenuAction };
