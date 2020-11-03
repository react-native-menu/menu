//
//  MenuView.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/3/20.
//

import UIKit
@available(iOS 14.0, *)
@objc(MenuView)
class MenuView: UIButton {

    private var _menuTitle: String?;
    @objc var menuTitle: NSString? {
        didSet {
            guard let menuTitle = self.menuTitle else {
                return
            }
            self._menuTitle = menuTitle as String
            self.setup()
        }
    }
    @objc var onPressAction: RCTDirectEventBlock?
    @objc var actions: NSArray?
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
    
    func setup () {
        let addCat = UIAction(title: "Add to List", image: UIImage(systemName: "plus"), identifier: UIAction.Identifier(rawValue: "add")) { (action) in
            self.sendButtonAction(action)
        }
        let shareButton = UIAction(title: "Share List", image: UIImage(systemName: "paperplane"), identifier: UIAction.Identifier(rawValue: "share")) { (action) in
            self.sendButtonAction(action)
        }
        let title = ((self._menuTitle != nil) ? self._menuTitle : "") ?? ""
        let menu = UIMenu(title:title, identifier: nil, options: .displayInline, children: [addCat, shareButton])

        self.menu = menu
        self.showsMenuAsPrimaryAction = true
        
    }
    
    override func reactSetFrame(_ frame: CGRect) {
      super.reactSetFrame(frame);
    };
    
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
        
    @objc func sendButtonAction(_ action: UIAction) {
        if onPressAction != nil {
            onPressAction!(["event":action.identifier.rawValue])
            
        }
    }
}
