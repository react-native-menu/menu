//
//  RCTMenuItem.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/8/20.
//

import UIKit;

@available(iOS 13.0, *)
class RCTMenuAction {
    
    var title: String;
    
    init(details: NSDictionary){
        let title = details["title"] as? NSString;
        self.title = title! as String;
    }
    
    func createUIAction(_ handler: @escaping UIActionHandler) -> UIAction {
        return UIAction(title: self.title, image: nil, identifier: nil, discoverabilityTitle: self.title, attributes: [], state: .off, handler: handler)
    }
}
