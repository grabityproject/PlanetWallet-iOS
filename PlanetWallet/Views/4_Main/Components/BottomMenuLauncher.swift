//
//  BottomMenuLauncher.swift
//  PlanetWallet
//
//  Created by grabity on 27/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BottomMenuLauncher: NSObject {
    
    var isOpen : Bool = false
    var controller:PlanetWalletViewController!
    
    var planet: Planet? {
        didSet {
            guard let planet = self.planet else { return }
            launcherView.setPlanet(planet)
            if let bottomPanelComponent = bottomPanelComponent{
                bottomPanelComponent.setPlanet(planet)
            }
        }
    }
    
    var bottomPanelComponent:BottomPanelComponent?{
        didSet{
            bottomPanelComponent?.controller(self.controller)
            bottomPanelComponent?.delegate = self
        }
    }
    
    private var view: UIView!
    private var triggerView : UIView!
    private var clicktriggerView : UIView!
    
    private let triggerAreaView: UIView = UIView()
    private let clicktriggerAreaView : UIView = UIView()
    
    private var launcherView: BottomMenuView!

    private let dimView = UIView()
    
    var triggerPanGesture : UIPanGestureRecognizer!
    var triggerTapGesture: UITapGestureRecognizer!
    var backgroundPanGesture : UIPanGestureRecognizer!
    var tapGesture : UITapGestureRecognizer!
    
    var topPosition : CGPoint!
    
    public var labelError : UIView!

    //MARK: - Init
    init( controller:PlanetWalletViewController, trigger:UIView, clickTrigger:UIView ) {
        super.init()
        self.controller = controller
        self.view = controller.view
        self.triggerView = trigger
        self.clicktriggerView = clickTrigger
        self.topPosition = CGPoint(x: trigger.frame.origin.x, y: trigger.frame.origin.y)
        
        launcherView = BottomMenuView(frame: CGRect(x: trigger.frame.origin.x, y: trigger.frame.origin.y, width: trigger.frame.width, height: 0))
        
        triggerAreaView.frame = trigger.frame
        
        let clickTriggerWidth = clickTrigger.frame.width + 15
        clicktriggerAreaView.frame = CGRect(x: triggerView.frame.width - clickTriggerWidth - 16,
                                            y: 20,
                                            width: clickTriggerWidth,
                                            height: clickTriggerWidth)
        
        dimView.frame = CGRect(x: 0, y: 0, width: controller.view.frame.width, height: controller.view.frame.height - launcherView.frame.height + 40)
        dimView.backgroundColor = .clear
        dimView.isHidden = true
        launcherView.alpha = 0
        
        controller.view.addSubviews(launcherView, triggerAreaView, dimView)
        triggerAreaView.addSubview(clicktriggerAreaView)
        
        triggerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(triggerPanAction));
        triggerAreaView.addGestureRecognizer(triggerPanGesture)
        triggerTapGesture = UITapGestureRecognizer(target: self, action: #selector(triggerTapAction))
        triggerAreaView.addGestureRecognizer(triggerTapGesture)

        backgroundPanGesture = UIPanGestureRecognizer(target: self, action: #selector(backgroundPanAction));
        dimView.addGestureRecognizer(backgroundPanGesture)

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClick))
        clicktriggerAreaView.addGestureRecognizer(tapGesture)

        setTheme(ThemeManager.currentTheme())
        
        launcherView.launcher = self
        launcherView.controller(controller)
    }
    
    @objc func onClick(_ sender:Any){
        bottomPanelComponent?.onClick();
    }
    
    @objc func triggerTapAction(_ sender: Any) {
        if( !isOpen ){
            self.show()
        }
    }
    
    @objc func triggerPanAction(_ sender: Any) {
        if(  triggerPanGesture.state == UIGestureRecognizer.State.changed  ){

            if( !isOpen ){
                let movePoint : CGFloat  = topPosition.y + triggerPanGesture.translation(in: launcherView).y

                if(  UIScreen.main.bounds.height - launcherView.frame.height  < movePoint && movePoint < topPosition.y ){
                    
                    self.launcherView.alpha = -( ( triggerPanGesture.translation(in: launcherView).y ) / 80) * 1.2
                    self.triggerView.alpha = ( 1.0 + ( ( triggerPanGesture.translation(in: launcherView).y ) / 80) )
                    self.labelError?.alpha = ( 1.0 + ( ( triggerPanGesture.translation(in: launcherView).y ) / 80) )
                    
                    launcherView.frame = CGRect(x: 0, y: movePoint, width: launcherView.frame.width, height: launcherView.frame.height)
                    triggerView.frame = CGRect(x: triggerView.frame.origin.x, y: movePoint, width: triggerView.frame.width, height: triggerView.frame.height)
                    
                    if let label = labelError{
                        label.frame = CGRect(x: label.frame.origin.x,
                                             y: movePoint - label.frame.height,
                                             width: label.frame.width,
                                             height: label.frame.height)
                    }
                }
                
            }else{
                let movePoint : CGFloat  = UIScreen.main.bounds.height - launcherView.frame.height + triggerPanGesture.translation(in: launcherView).y
                
                if( movePoint > UIScreen.main.bounds.height - launcherView.frame.height
                    && movePoint < UIScreen.main.bounds.height - 80 ){
                    
                    let movePercent = (movePoint - ( UIScreen.main.bounds.height - 160 ) ) / 80
                    if( movePercent > 0 ){
                        self.launcherView.alpha = ( 1.0 - movePercent )*1.2
                        self.triggerView.alpha = movePercent
                        self.labelError?.alpha = movePoint
                    }

                    launcherView.frame = CGRect(x: 0, y: movePoint, width: launcherView.frame.width, height: launcherView.frame.height)
                    triggerView.frame = CGRect(x: triggerView.frame.origin.x, y: movePoint, width: triggerView.frame.width, height: triggerView.frame.height)

                    if let label = labelError{
                        label.frame = CGRect(x: label.frame.origin.x,
                                             y: movePoint - label.frame.height,
                                             width: label.frame.width,
                                             height: label.frame.height)
                    }
                }
            }
            
        }else if(  triggerPanGesture.state == UIGestureRecognizer.State.ended  ){
            
            UIView.animate(withDuration: 0.2) {
                if( ( -self.launcherView.frame.height*2.0/5.0 > ( -80 + self.triggerPanGesture.translation(in: self.launcherView).y ) ) && !self.isOpen ){
                   
                    self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                    self.launcherView.alpha = 1.0
                    self.triggerView.alpha = 0
                    self.isOpen = true;
                    self.dimView.isHidden = false;
                    self.triggerAreaView.isUserInteractionEnabled  = false;
                    
                }else if( UIScreen.main.bounds.height - self.launcherView.frame.height*4.0/5.0 < ( UIScreen.main.bounds.height - self.launcherView.frame.height + self.triggerPanGesture.translation(in:
                    
                    self.launcherView).y ) && self.isOpen ){
                    self.launcherView.frame = CGRect(x: 0, y: self.topPosition.y, width: self.launcherView.frame.width, height: self.launcherView.frame.height)
                    
                    
                    if let label =  self.labelError{
                        label.frame = CGRect(x: label.frame.origin.x,
                                             y: self.topPosition.y - label.frame.height,
                                             width: label.frame.width,
                                             height: label.frame.height)
                        label.alpha = 1
                    }
                    
                    self.launcherView.alpha = 0
                    self.triggerView.alpha = 1
                    self.isOpen = false;
                    self.triggerAreaView.isUserInteractionEnabled  = true;
                    self.dimView.isHidden = true;
                    
                }else{
                    if( self.isOpen ){
                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                        self.launcherView.alpha = 1
                        self.triggerView.alpha = 0
                        self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
                        
                        
                        if let label = self.labelError{
                            label.frame = CGRect(x: label.frame.origin.x,
                                                 y: UIScreen.main.bounds.height - self.launcherView.frame.height - label.frame.height,
                                                 width: label.frame.width,
                                                 height: label.frame.height)
                            label.alpha = 0
                        }
                        
                    }else{
                        self.launcherView.frame = CGRect(x: 0, y: self.topPosition.y, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                        self.launcherView.alpha = 0
                        self.triggerView.alpha = 1
                        self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: self.topPosition.y, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
                        
                        
                        if let label =  self.labelError{
                            label.frame = CGRect(x: label.frame.origin.x,
                                                 y: self.topPosition.y - label.frame.height,
                                                 width: label.frame.width,
                                                 height: label.frame.height)

                            label.alpha = 1
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    
    
    @objc func backgroundPanAction(_ sender: Any) {
        
        if(  backgroundPanGesture.state == UIGestureRecognizer.State.changed  ){
            
            let movePoint : CGFloat  = UIScreen.main.bounds.height - launcherView.frame.height + backgroundPanGesture.translation(in: dimView).y
            print(movePoint)
            if( movePoint > UIScreen.main.bounds.height - launcherView.frame.height && movePoint < topPosition.y ){

                let movePercent = ( movePoint - ( UIScreen.main.bounds.height - 240 ) ) / 80
                if( movePercent > 0 ){
                    self.launcherView.alpha = ( 1.0 - movePercent )*1.2
                    self.triggerView.alpha = movePercent
                    self.labelError?.alpha = movePercent
                }
                launcherView.frame = CGRect(x: 0, y: movePoint, width: launcherView.frame.width, height: launcherView.frame.height)
                triggerView.frame = CGRect(x: triggerView.frame.origin.x, y: movePoint, width: triggerView.frame.width, height: triggerView.frame.height)
                
                
                if let label =  self.labelError{
                    label.frame =  CGRect(x: label.frame.origin.x,
                                          y: movePoint - label.frame.height,
                                          width: label.frame.width,
                                          height: label.frame.height)
                }
                

            }
            
            
        }else if(  backgroundPanGesture.state == UIGestureRecognizer.State.ended  ){
            
            UIView.animate(withDuration: 0.2) {
                if( -self.launcherView.frame.height*4.0/5.0 < ( -self.launcherView.frame.height + self.backgroundPanGesture.translation(in: self.dimView).y ) && self.isOpen ){
                    
                    self.launcherView.frame = CGRect(x: 0, y: self.topPosition.y, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                    self.launcherView.alpha = 0
                    self.triggerView.alpha = 1
                    self.isOpen = false;
                    self.triggerAreaView.isUserInteractionEnabled  = true;

                    self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: self.topPosition.y, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
                    self.dimView.isHidden = true;
                    
                    if let label =  self.labelError{
                        label.frame =  CGRect(x: 0,
                                              y: self.topPosition.y - label.frame.height,
                                              width: label.frame.width,
                                              height: label.frame.height);
                        label.alpha = 1
                    }

                }else{
                    if( self.isOpen ){
                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                        self.launcherView.alpha = 1
                        self.triggerView.alpha = 0
                        self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.triggerView.frame.width, height: self.triggerView.frame.height)

                        
                        if let label =  self.labelError{
                            label.frame = CGRect(x: label.frame.origin.x,
                                                 y: UIScreen.main.bounds.height - self.launcherView.frame.height - label.frame.height,
                                                 width: label.frame.width,
                                                 height: label.frame.height)
                            
                            label.alpha = 0
                        }

                    }else{
                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                        self.launcherView.alpha = 0
                        self.triggerView.alpha = 1
                        self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: self.topPosition.y, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
                        
                        
                        if let label =  self.labelError{
                            label.frame =  CGRect(x: label.frame.origin.x,
                                                  y: self.topPosition.y - label.frame.height,
                                                  width: label.frame.width,
                                                  height: label.frame.height)
                            
                            label.alpha = 1
                        }

                    }
                }
            }
        }
    }
    
    public func setTheme(_ theme: Theme) {
        findAllViews(view: launcherView, theme: theme)

        if( theme == .LIGHT ){
            launcherView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            launcherView.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            launcherView.layer.shadowRadius = 8
            launcherView.layer.shadowOpacity = 0.2
            launcherView.layer.masksToBounds = false
        }else{
            launcherView.dropShadow(radius: 0, cornerRadius: 0)
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
    
    //MARK: - Interface
    public func show() {
        if isOpen == true { return }
        UIView.animate(withDuration: 0.2) {
            self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
            self.launcherView.alpha = 1.0
            self.triggerView.alpha = 0
            self.isOpen = true;
            self.triggerAreaView.isUserInteractionEnabled  = false;
            self.dimView.isHidden = false;
            if let label = self.labelError{
                label.frame = CGRect(x: 0,
                                     y: UIScreen.main.bounds.height - self.launcherView.frame.height - label.frame.height,
                                     width: label.frame.width,
                                     height: label.frame.height)
                label.alpha = 0
            }
        }
    }
    
    public func hide() {
        if isOpen == false { return }
        
        UIView.animate(withDuration: 0.2) {
            
            self.launcherView.frame = CGRect(x: 0, y: self.topPosition.y, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
            self.launcherView.alpha = 0
            self.triggerView.alpha = 1
            self.isOpen = false;
            self.triggerAreaView.isUserInteractionEnabled  = true;
            
            self.triggerView.frame = CGRect(x: self.triggerView.frame.origin.x, y: self.topPosition.y, width: self.triggerView.frame.width, height: self.triggerView.frame.height)
            self.dimView.isHidden = true;
            
            if let label =  self.labelError{
                label.frame =  CGRect(x: 0,
                                      y: self.topPosition.y - label.frame.height,
                                      width: label.frame.width,
                                      height: label.frame.height);
                label.alpha = 1
            }

        }
    }
}

extension BottomMenuLauncher: BottomPanelDelegate {
    func didSwitched(_ mainItem: MainItem) {
        launcherView.mainItem = mainItem
    }
}
