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
   
    // Presentation is tracked from the two delegate methods the class already
    // overrode. Overriding willDisplayMenuFor as well (even for bookkeeping)
    // shadows UIButton's own implementation and degrades the button-anchored
    // presentation into generic context-menu chrome — an empty header row with
    // a dismiss chevron appears above the actions.
    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        // Flush updates deferred by the presented-guard before the action
        // provider snapshots self.menu (covers a stuck flag from an
        // interaction that never ended cleanly).
        if pendingMenu != nil {
            pendingMenu = nil
            isMenuPresented = false
            self.setup()
        }
        isMenuPresented = true
        sendMenuOpen()
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            return self.menu
        }
    }
    
    public override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        sendMenuClose()
        isMenuPresented = false
        if pendingMenu != nil {
            pendingMenu = nil
            self.setup()
        }
    }

    private var isMenuPresented = false
    private var pendingMenu: UIMenu?

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

        if isMenuPresented {
            pendingMenu = menu
            self.refreshPresentedMenu(menu)
            return
        }

        self.menu = menu
        self.showsMenuAsPrimaryAction = !shouldOpenOnLongPress
    }

    private func refreshPresentedMenu(_ menu: UIMenu) {
        var candidates = self.interactions.compactMap { $0 as? UIContextMenuInteraction }
        if let interaction = self.contextMenuInteraction {
            candidates.append(interaction)
        }

        var visited: Set<ObjectIdentifier> = []
        for interaction in candidates where visited.insert(ObjectIdentifier(interaction)).inserted {
            interaction.updateVisibleMenu { _ in menu }
        }
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
