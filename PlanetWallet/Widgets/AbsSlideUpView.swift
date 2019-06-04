//
//  AbsSlideUpView.swift
//  PlanetViewTest
//
//  Created by 박상은 on 13/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit


class AbsSlideUpView: PWView, UIGestureRecognizerDelegate {
    
    private var background : UIView = UIView()
    public var dimAlpha: CGFloat {
        switch ThemeManager.currentTheme() {
        case .DARK:     return 0.5
        case .LIGHT:    return 0.1
        }
    }
    
    var contentView : UIView?
    private var controller : UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createView() {
        setXib()
        if( controller != nil ){
            self.frame = CGRect(x: 0, y: 0, width: (controller?.view.bounds.width)!, height: (controller?.view.bounds.height)!)
            background.frame = CGRect(x: 0, y: 0, width: (controller?.view.bounds.width)!, height: (controller?.view.bounds.height)!)
            background.backgroundColor = UIColor.black
            background.alpha = 0.0;
            background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tabBackground)))
            
            addSubview(background)
            controller!.view.addSubview(self)
            
            if( contentView != nil ){
                addSubview(contentView!)
                contentView?.frame = CGRect(
                    x: (self.bounds.width - (contentView?.bounds.width)!)/2,
                    y: (self.bounds.height - (contentView?.bounds.height)!)/2 + (controller?.view.bounds.height)!,
                    width: (contentView?.bounds.width)!,
                    height: (contentView?.bounds.height)!)
            }
        }
    }
    
    func setXib(){
    }
    
    public func show( controller:UIViewController ) {
        self.controller = controller;
        createView();
        
        guard let v = contentView else { return }
        
        v.frame = CGRect(x: 30.5,
                         y: controller.view.frame.height,//( controller.view.frame.height - v.frame.size.height )/2.0,
                         width: controller.view.frame.width - 30.5*2.0,
                         height: v.frame.height)
        
        UIView.animate(withDuration: 0.4) {
            self.background.alpha = self.dimAlpha
            v.frame = CGRect(
                x: (self.bounds.width - (self.contentView?.bounds.width)!)/2,
                y: (self.bounds.height - (self.contentView?.bounds.height)!)/2,
                width: (self.contentView?.bounds.width)!,
                height: (self.contentView?.bounds.height)!)
        }
    }
    
    public func dismiss(){
        UIView.animate(withDuration: 0.4, animations: {
            self.background.alpha = 0.0
            self.contentView?.frame = CGRect(
                x: (self.bounds.width - (self.contentView?.bounds.width)!)/2,
                y: (self.bounds.height - (self.contentView?.bounds.height)!)/2 + (self.controller?.view.bounds.height)!,
                width: (self.contentView?.bounds.width)!,
                height: (self.contentView?.bounds.height)!)
        }) { (result) in
            self.removeFromSuperview()
        }
    }
    
    @objc func tabBackground(sender: UITapGestureRecognizer) {
        dismiss()
    }
}
