import { jsx as _jsx } from "react/jsx-runtime";
import { useMemo } from "react";
import { processColor } from "react-native";
import UIMenuView from "./UIMenuView";
import { objectHash } from "./utils";
function processAction(action) {
    return {
        ...action,
        imageColor: processColor(action.imageColor),
        titleColor: processColor(action.titleColor),
        subactions: action.subactions?.map((subAction) => processAction(subAction)),
    };
}
const defaultHitslop = { top: 0, left: 0, bottom: 0, right: 0 };
const MenuView = ({ actions, hitSlop = defaultHitslop, ...props }) => {
    const processedActions = actions.map((action) => processAction(action));
    const hash = useMemo(() => {
        return objectHash(processedActions);
    }, [processedActions]);
    return (_jsx(UIMenuView, { ...props, hitSlop: hitSlop, actions: processedActions, actionsHash: hash }));
};
export { MenuView };
