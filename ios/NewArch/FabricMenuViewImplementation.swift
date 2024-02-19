//
//  MenuViewImplementation.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/3/20.
//

import UIKit
@available(iOS 14.0, *)
@objc(FabricMenuViewImplementation)
public class FabricMenuViewImplementation: MenuViewImplementation, FabricViewImplementationProtocol {
    public var onPressAction: ((String) -> Void)?
    
    @objc override func sendButtonAction(_ action: UIAction) {
        if let onPress = onPressAction {
            onPress(action.identifier.rawValue)
        }
    }

}
