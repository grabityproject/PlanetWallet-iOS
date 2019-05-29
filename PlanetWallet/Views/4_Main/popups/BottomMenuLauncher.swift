//
//  BottomMenuLauncher.swift
//  PlanetWallet
//
//  Created by grabity on 27/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BottomMenuLauncher: NSObject {
    
    private let triggerView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        
        return view
    }()
    
    private let launcherView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        
        return view
    }()
    
    private let dimView = UIView()
  
    private let height: CGFloat = 441
    
    
    //MARK: - Init
    override init() {
        super.init()
        
        if let window = UIApplication.shared.keyWindow {
            
            triggerView.frame = CGRect(x: 0,
                                       y: SCREEN_HEIGHT - 80,
                                       width: SCREEN_WIDTH,
                                       height: 80)
            
            launcherView.frame = CGRect(x: 0,
                                    y: SCREEN_HEIGHT,
                                    width: window.frame.width,
                                    height: height)
            
            dimView.frame = window.bounds
            dimView.backgroundColor = .clear
            dimView.isHidden = true
            
            window.addSubviews(triggerView, dimView, launcherView)
        }
        
        configureGesture()
        setTheme(ThemeManager.currentTheme())
    }
    
    //MARK: - Interface
    @objc public func handleDismiss() {
        UIView.animate(withDuration: 0.8) {
            self.launcherView.frame = CGRect(x: 0,
                                         y: SCREEN_HEIGHT,
                                         width: self.launcherView.frame.width,
                                         height: self.launcherView.frame.height)
        }
    }
    
    //MARK: - Private
    private func configureGesture() {
//        let panDownGesture = UIPanGestureRecognizer(target: self,
//                                                    action: #selector(handlePanDownGesture(_:)))
        let panUpGesture = UIPanGestureRecognizer(target: self,
                                                  action: #selector(handlePanUpGesture(_:)))
        let dimPanUpGesture = UIPanGestureRecognizer(target: self,
                                                     action: #selector(handlePanUpGesture(_:)))
        
        self.triggerView.addGestureRecognizer(panUpGesture)
        self.dimView.addGestureRecognizer(dimPanUpGesture)
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        showMenuWithAnimation()
    }
    
    @objc private func handlePanDownGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let location = recognizer.translation(in: window)
        
        let width = window.bounds.width
        
        let triggerViewPositionY = triggerView.frame.midY
        launcherView.frame = CGRect(x: 0, y: location.y - height + triggerViewPositionY, width: width, height: height)
        
        let maxY = launcherView.frame.maxY
        //위로 올릴지 아래로 내릴지 판단하는 기준
        let borderY = height * (2 / 5)
        
        if maxY >= height {
            launcherView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        
        if recognizer.state == .ended {
            
            if maxY > borderY { //end gesture
                UIView.animate(withDuration: 0.25) {
                    self.launcherView.frame = CGRect(x: 0, y: 0, width: width, height: self.height)
                }
                dimView.isHidden = false
            }
            else {
                UIView.animate(withDuration: 0.25) {
                    self.launcherView.frame = CGRect(x: 0, y: -self.height, width: width, height: self.height)
                }
            }
        }
    }
    
    @objc private func handlePanUpGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let location = recognizer.translation(in: window)
        let width = window.bounds.width
        
        print(location.y)
        
        launcherView.frame = CGRect(x: 0,
                                    y: SCREEN_HEIGHT + location.y,
                                    width: width,
                                    height: height)
        
        let minY = launcherView.frame.minY
        //위로 올릴지 아래로 내릴지 판단하는 기준
        let borderY = height * (4 / 5)
        
        if minY <= height {
            launcherView.frame = CGRect(x: 0, y: SCREEN_HEIGHT - height, width: width, height: height)
        }
        
        
        if recognizer.state == .ended {
            
            if minY > borderY {
                UIView.animate(withDuration: 0.25) {
                    self.launcherView.frame = CGRect(x: 0, y: 0, width: width, height: self.height)
                }
            }
            else {  //end gesture
                UIView.animate(withDuration: 0.25) {
                    self.launcherView.frame = CGRect(x: 0, y: -self.height, width: width, height: self.height)
                }
                dimView.isHidden = true
            }
        }
    }
    
    private func showMenuWithAnimation() {
        //animate fade in,out
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.launcherView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.launcherView.frame.width,
                                         height: self.launcherView.frame.height)
        }, completion: { (_) in
            self.dimView.isHidden = false
        })
    }
    
    public func setTheme(_ theme: Theme) {
        findAllViews(view: launcherView, theme: theme)
        
        if( theme == .LIGHT ){
            launcherView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            launcherView.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            launcherView.layer.shadowRadius = 8
            launcherView.layer.shadowOpacity = 0.45
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
}
