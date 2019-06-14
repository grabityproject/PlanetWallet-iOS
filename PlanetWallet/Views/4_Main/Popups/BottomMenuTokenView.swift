//
//  BottomMenuTokenView.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BottomMenuTokenView: UIView {

    @IBOutlet var dimView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var popupContentView: UIView!
    
    var backgroundPanGesture : UIPanGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("BottomMenuTokenView", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        self.addSubview(containerView)
        
        popupContentView.layer.cornerRadius = 25
        popupContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        popupContentView.layer.masksToBounds = true
        
        backgroundPanGesture = UIPanGestureRecognizer(target: self, action: #selector(backgroundPanAction));
        dimView.addGestureRecognizer(backgroundPanGesture)
        
        setTheme(ThemeManager.currentTheme())
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedTransfer(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func didTouchedCopy(_ sender: UIButton) {
        
    }
    
    //MARK: - Interface
    public func show() {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: SCREEN_WIDTH,
                                height: SCREEN_HEIGHT)
        }
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: 0,
                                y: SCREEN_HEIGHT,
                                width: SCREEN_WIDTH,
                                height: SCREEN_HEIGHT)
        }
    }
    
    //MARK: - Private
    private func setTheme(_ theme: Theme) {
        findAllViews(view: containerView, theme: theme)
        
        if( theme == .LIGHT ){
            popupContentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            popupContentView.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            popupContentView.layer.shadowRadius = 8
            popupContentView.layer.shadowOpacity = 0.2
            popupContentView.layer.masksToBounds = false
        }else{
            popupContentView.dropShadow(radius: 0, cornerRadius: 0)
        }
    }
    
    private func findAllViews( view:UIView, theme:Theme ){
        
        if( view is Themable ){
            (view as! Themable).setTheme(theme)
        }
        
        if( view.subviews.count > 0 ){
            view.subviews.forEach { (v) in
                
                findAllViews(view: v, theme: theme)
            }
        }
    }
    
    @objc func backgroundPanAction(_ sender: Any) {
        if(  backgroundPanGesture.state == UIGestureRecognizer.State.changed  ){
            
            let movePoint : CGFloat  = backgroundPanGesture.translation(in: dimView).y

            print(-self.frame.height * 0.8)
            print(-self.frame.height + movePoint)
            
            if movePoint > 0 {
                self.frame = CGRect(x: 0,
                                    y: movePoint,
                                    width: self.frame.width,
                                    height: self.frame.height)
            }
        }
        else if backgroundPanGesture.state == UIGestureRecognizer.State.ended
        {
            let updownBorder = self.frame.height * 0.8
            let movePoint = self.backgroundPanGesture.translation(in: self.dimView).y
            
            
            UIView.animate(withDuration: 0.2) {
                if( -updownBorder <  -self.frame.height + movePoint ){
                    self.frame = CGRect(x: 0,
                                        y: SCREEN_HEIGHT,
                                        width: self.frame.width,
                                        height: self.frame.height);
                    
                }else{
                    self.frame = CGRect(x: 0,
                                        y: 0,
                                        width: self.frame.width,
                                        height: self.frame.height);
//                    if( self.isOpen ){
//                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
//                        self.launcherView.alpha = 1
//                        self.triggerView.alpha = 0
//                        self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
//
//                    }else{
//                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
//                        self.launcherView.alpha = 0
//                        self.triggerView.alpha = 1
//                        self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: self.topPosition.y, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
//
//                    }
                }
            }
            
        }
    }
}
