//
//  RCTMenuItem.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/8/20.
//

import UIKit;

@available(iOS 13.0, *)
class RCTMenuAction {

    var identifier: UIAction.Identifier?;
    var title: String;
    var subtitle: String?
    var displayInline: Bool
    var image: UIImage?
    var attributes: UIAction.Attributes = []
    var state: UIAction.State = .off
    var subactions: [RCTMenuAction] = []
    // Only available in iOS 16+
    var preferredElementSizeString: String?

    init(details: NSDictionary){

        if let identifier = details["id"] as? NSString {
            self.identifier = UIAction.Identifier(rawValue: identifier as String);
        }

        if let image = details["image"] as? NSString {
            self.image = UIImage(systemName: image as String);
            if self.image === nil {
                self.image = UIImage(named: image as String)
            }
            if let imageColor = details["imageColor"] {
                self.image = self.image?.withTintColor(RCTConvert.uiColor(imageColor), renderingMode: .alwaysOriginal)
            }
        }

        if let title = details["title"] as? NSString {
            self.title = title as String;
        } else {
            self.title = "";
        }

        if let subtitle = details["subtitle"] as? NSString {
            self.subtitle = subtitle as String;
        }

        if let displayInline = details["displayInline"] as? Bool {
            self.displayInline = displayInline as Bool;
        } else {
            self.displayInline = false;
        }

        if let attributes = details["attributes"] as? NSDictionary {
            if (attributes["destructive"] as? Bool) == true {
                self.attributes.update(with: .destructive)
            }
            if (attributes["disabled"] as? Bool) == true {
                self.attributes.update(with: .disabled)
            }
            if (attributes["hidden"] as? Bool) == true {
                self.attributes.update(with: .hidden)
            }
            if(attributes["keepsMenuPresented"] as? Bool) == true {
                if #available(iOS 16.0, *) {
                    self.attributes.update(with: .keepsMenuPresented)
                } 
            }
        }

        if let state = details["state"] as? NSString {
            if state=="on" {
                self.state = .on
            }
            if state=="off" {
                self.state = .off
            }
            if state=="mixed" {
                self.state = .mixed
            }
        }

        if let subactions = details["subactions"] as? NSArray {
            if subactions.count > 0 {
                for subaction in subactions {
                    self.subactions.append(RCTMenuAction(details: subaction as! NSDictionary))
                }
            }
        }

        if let preferredElementSizeString = details["preferredElementSize"] as? String {
            self.preferredElementSizeString = preferredElementSizeString
        }

    }

    func createUIMenuElement(_ handler: @escaping UIActionHandler) -> UIMenuElement {
        if subactions.count > 0 {
            var subMenuActions: [UIMenuElement] = []
            subactions.forEach { subaction in
                subMenuActions.append(subaction.createUIMenuElement(handler))
            }
            var menu: UIMenu;
            if self.displayInline {
                menu = UIMenu(title: title, image: image, options: .displayInline, children: subMenuActions)
            } else {
                menu = UIMenu(title: title, image: image, children: subMenuActions)
            }

            if #available(iOS 16.0, *) {
                if(preferredElementSizeString == "small") {
                    menu.preferredElementSize = .small
                } else if(preferredElementSizeString == "medium") {
                    menu.preferredElementSize = .medium
                } else if(preferredElementSizeString == "large") {
                    menu.preferredElementSize = .large
                }
            }

            return menu
        }

        if #available(iOS 15, *) {
            return UIAction(title: title, subtitle: subtitle, image: image, identifier: identifier, attributes: attributes, state: state, handler: handler)
        } else {
            return UIAction(title: title, image: image, identifier: identifier, discoverabilityTitle: subtitle, attributes: attributes, state: state, handler: handler)
        }
    }
}
