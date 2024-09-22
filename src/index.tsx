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

const defaultHitslop = { top: 0, left: 0, bottom: 0, right: 0 };

const MenuView: React.FC<MenuComponentProps> = ({
  actions,
  hitSlop = defaultHitslop,
  ...props
}) => {
  const processedActions = actions.map<ProcessedMenuAction>((action) =>
    processAction(action)
  );
  const hash = useMemo(() => {
    return objectHash(processedActions);
  }, [processedActions]);
  return (
    <UIMenuView
      {...props}
      hitSlop={hitSlop}
      actions={processedActions}
      actionsHash={hash}
    />
  );
};

export { MenuView };
export type { MenuComponentProps, MenuAction, NativeActionEvent };
