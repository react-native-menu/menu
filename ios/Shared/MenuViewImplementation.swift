//
//  MenuViewImplementation.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/3/20.
//

import UIKit
@available(iOS 14.0, *)
@objc(MenuViewImplementation)
public class MenuViewImplementation: UIButton {

    @objc public var actions: [NSDictionary]? {
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

    private var _actions: [UIMenuElement] = [];

    private var _title: String = "";
    @objc public var title: NSString? {
        didSet {
            guard let title = self.title else {
                return
            }
            self._title = title as String
            self.setup()
        }
    }

    @objc public var shouldOpenOnLongPress: Bool = false {
        didSet {
            self.setup()
        }
    }

    private var _themeVariant: String?
    @objc public var themeVariant: NSString? {
        didSet {
            self._themeVariant = themeVariant as? String
            self.setup()
        }
    }

    @objc public var hitSlop: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
        self.setup()
    }
   
    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        sendMenuOpen()
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            return self.menu
        }
    }
    
    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        sendMenuClose()
    }

    func setup () {
        let menu = UIMenu(title: _title,
            identifier: nil,
            children: self._actions)

        if self._themeVariant != nil {
            if self._themeVariant == "dark" {
                self.overrideUserInterfaceStyle = .dark
            } else if self._themeVariant == "light" {
                self.overrideUserInterfaceStyle = .light
            } else {
                self.overrideUserInterfaceStyle = .unspecified
            }
        }

        self.menu = menu
        self.showsMenuAsPrimaryAction = !shouldOpenOnLongPress
    }

    public override func reactSetFrame(_ frame: CGRect) {
        super.reactSetFrame(frame);
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if hitSlop == .zero || !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
        }

        let largerFrame = CGRect(
            x: self.bounds.origin.x - hitSlop.left,
            y: self.bounds.origin.y - hitSlop.top,
            width: self.bounds.size.width + hitSlop.left + hitSlop.right,
            height: self.bounds.size.height + hitSlop.top + hitSlop.bottom
        )

        return largerFrame.contains(point)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func sendButtonAction(_ action: UIAction) {
        // NO-OP (should be overriden by parent)
    }

    @objc func sendMenuClose() {
        // NO-OP (should be overriden by parent)
    }

    @objc func sendMenuOpen() {
        // NO-OP (should be overriden by parent)
    }
}
