//
//  RCTAlertAction.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/9/20.
//

import UIKit;

class RCTAlertAction {
    
    var identifier: String?;
    var title: String;
    var image: UIImage?
    var style: UIAlertAction.Style = .default
    var isEnabled: Bool = true
    var isHidden: Bool = false
    
    init(details: NSDictionary){
        
        if let identifier = details["id"] as? NSString {
            self.identifier = identifier as String;
        }
                        
        if let title = details["title"] as? NSString {
            self.title = title as String;
        } else {
            self.title = "";
        }
                
        if let image = details["image"] as? NSString {
            if #available(iOS 13.0, *) {
                self.image = UIImage(systemName: image as String)
                if let imageColor = details["imageColor"] {
                    self.image = self.image?.withTintColor(RCTConvert.uiColor(imageColor), renderingMode: .alwaysOriginal)
                }
            } else {
                self.image = UIImage(named: image as String)
            };
        }
        
        if let attributes = details["attributes"] as? NSDictionary {
            if (attributes["destructive"] as? Bool) == true {
                self.style = .destructive
            }
            if (attributes["disabled"] as? Bool) == true {
                self.isEnabled = false
            }
            if (attributes["hidden"] as? Bool == true){
                self.isHidden = true
            }
        }
        
    }
    
    func createAction(_ handleEvent: @escaping ((String) -> Void)) -> UIAlertAction? {
        if self.isHidden {
            return nil
        }
        let action = UIAlertAction(title: title, style: style, handler: {_ in
            handleEvent(self.identifier ?? self.title)
        })
        if self.image != nil {
            action.setValue(self.image, forKey: "image")
        }
        action.isEnabled = self.isEnabled
        
        return action
    }
}

