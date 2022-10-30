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

    private var _actions: [UIMenuElement] = [];
    @objc var actions: [NSDictionary]? {
        didSet {
            guard let actions = self.actions else {
                return
            }
            _actions.removeAll()
            actions.forEach { menuAction in
                _actions.append(RCTMenuAction(details: menuAction).createUIMenuElement({action in self.sendButtonAction(action)}))
            }
            self.setup()
        }
    }

    private var _title: String = "";
    @objc var title: NSString? {
        didSet {
            guard let title = self.title else {
                return
            }
            self._title = title as String
            self.setup()
        }
    }
    @objc var onPressAction: RCTDirectEventBlock?

    @objc var shouldOpenOnLongPress: Bool = false {
        didSet {
            self.setup()
        }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
      self.setup()
    }


    func setup () {
        let menu = UIMenu(title:_title, identifier: nil, children: self._actions)

        self.menu = menu
        self.showsMenuAsPrimaryAction = !shouldOpenOnLongPress
    }

    override func reactSetFrame(_ frame: CGRect) {
      super.reactSetFrame(frame);
    };


  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

    @objc func sendButtonAction(_ action: UIAction) {
        if let onPress = onPressAction {
            onPress(["event":action.identifier.rawValue])
        }
    }
}
