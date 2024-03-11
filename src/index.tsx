import React, { useMemo } from 'react';
import { processColor } from 'react-native';

import UIMenuView from './UIMenuView';
import type {
  MenuComponentProps,
  MenuAction,
  ProcessedMenuAction,
  NativeActionEvent,
} from './types';
import { objectHash } from './utils';

function processAction(action: MenuAction): ProcessedMenuAction {
  return {
    ...action,
    imageColor: processColor(action.imageColor),
    titleColor: processColor(action.titleColor),
    subactions: action.subactions?.map((subAction) => processAction(subAction)),
  };
}

const MenuView: React.FC<MenuComponentProps> = ({ actions, ...props }) => {
  const processedActions = actions.map<ProcessedMenuAction>((action) =>
    processAction(action)
  );
  const hash = useMemo(() => {
    return objectHash(processedActions);
  }, [processedActions]);
  return (
    <UIMenuView {...props} actions={processedActions} actionsHash={hash} />
  );
};

export { MenuView };
export type { MenuComponentProps, MenuAction, NativeActionEvent };
