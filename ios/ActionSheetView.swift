//
//  MenuView.swift
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/3/20.
//

import UIKit


@objc(ActionSheetView)
class ActionSheetView: UIView {
    @objc var onPressAction: RCTDirectEventBlock?
    @objc var menuTitle: NSString?
    @objc var actions: NSArray?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.handleTap (_:)))
        self.addGestureRecognizer(tap)
    }
    
    func launchActionSheet() {

        let alert = UIAlertController(title: "My Alert",message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add to List", style: .default, handler: { action in self.sendButtonAction("add")}))
        alert.addAction(UIAlertAction(title: "Share List", style: .default, handler: { action in self.sendButtonAction("share")}))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let root = RCTPresentedViewController()
        root!.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
       // do other task
        DispatchQueue.main.async {
            self.launchActionSheet()
        }
    }
    
    @objc func sendButtonAction(_ action: String) {
        if onPressAction != nil {
            onPressAction!(["event":action])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reactSetFrame(_ frame: CGRect) {
      super.reactSetFrame(frame);
    };
    
}
