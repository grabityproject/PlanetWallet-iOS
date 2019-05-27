//
//  MainLauncher.swift
//  PlanetViewTest
//
//  Created by 박상은 on 24/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

@IBDesignable
class MainLauncher: UIView {
    
    var isOpen : Bool = false
    
    var background : UIView = UIView()
    var triggerPanGesture : UIPanGestureRecognizer!
    var backgroundPanGesture : UIPanGestureRecognizer!
    
    @IBOutlet var launcherView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    func viewInit( ) {
        Bundle.main.loadNibNamed("LauncherView", owner: self, options: nil)
                
        background.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height)
        
        launcherView.frame = CGRect(
            x: 0,
            y: UIScreen.main.bounds.height-80,
            width: UIScreen.main.bounds.width,
            height: launcherView.frame.height)
        
        
        addSubview(background)
        addSubview(launcherView)
        
        triggerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(triggerPanAction));
//        backgroundPanGesture = UIPanGestureRecognizer(target: self, action: #selector(backgroundPanAction));
        
        launcherView.addGestureRecognizer(triggerPanGesture)
//        background.addGestureRecognizer(backgroundPanGesture)

        background.isUserInteractionEnabled = false;
        
        containerView.layer.cornerRadius = 25
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        launcherView.layer.shadowColor = UIColor.black.cgColor
        launcherView.layer.shadowOffset = CGSize(width: 0, height: -1.0)
        launcherView.layer.shadowRadius = 8
        launcherView.layer.shadowOpacity = 0.16
        launcherView.layer.masksToBounds = false
    }
    
    
//    @objc func backgroundPanAction(_ sender: Any) {
//        
//        
//        if(  backgroundPanGesture.state == UIGestureRecognizer.State.changed  ){
//            
//            let movePoint : CGFloat  = UIScreen.main.bounds.height - launcherView.frame.height + backgroundPanGesture.translation(in: background).y
//            if( movePoint > UIScreen.main.bounds.height - launcherView.frame.height
//                && movePoint < UIScreen.main.bounds.height - 80 ){
//                
//                let movePercent = (movePoint - ( UIScreen.main.bounds.height - 160 ) ) / 80
//                if( movePercent > 0 ){
//                    self.containerView.alpha = ( 1.0 - movePercent )*1.2
//                    self.blurView.alpha = movePercent
//                }
//                launcherView.frame = CGRect(x: 0, y: movePoint, width: launcherView.frame.width, height: launcherView.frame.height)
//                
//            }
//            
//            
//        }else if(  backgroundPanGesture.state == UIGestureRecognizer.State.ended  ){
//            
//            UIView.animate(withDuration: 0.2) {
//                if( -self.launcherView.frame.height*4.0/5.0 < ( -self.launcherView.frame.height + self.backgroundPanGesture.translation(in: self.background).y ) && self.isOpen ){
//                    self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
//                    self.containerView.alpha = 0
//                    self.blurView.alpha = 1
//                    self.isOpen = false;
//                    
//                    self.background.isUserInteractionEnabled = false;
//                    
//                }else{
//                    if( self.isOpen ){
//                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
//                        self.containerView.alpha = 1
//                        self.blurView.alpha = 0
//                        
//                    }else{
//                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
//                        self.containerView.alpha = 0
//                        self.blurView.alpha = 1
//                        
//                    }
//                }
//            }
//        }
//    }
    
    @objc func triggerPanAction(_ sender: Any) {
        
        if(  triggerPanGesture.state == UIGestureRecognizer.State.changed  ){
            
            if( !isOpen ){
                let movePoint : CGFloat  = UIScreen.main.bounds.height - 80 + triggerPanGesture.translation(in: launcherView).y
                
                if( movePoint > UIScreen.main.bounds.height - launcherView.frame.height
                    && movePoint < UIScreen.main.bounds.height - 80 ){
                    
                    self.containerView.alpha = -( ( triggerPanGesture.translation(in: launcherView).y ) / 80)*1.2
                    self.blurView.alpha = ( 1.0 + ( ( triggerPanGesture.translation(in: launcherView).y ) / 80) )
                    
                    launcherView.frame = CGRect(x: 0, y: movePoint, width: launcherView.frame.width, height: launcherView.frame.height)
                    
                }
            }else{
                let movePoint : CGFloat  = UIScreen.main.bounds.height - launcherView.frame.height + triggerPanGesture.translation(in: launcherView).y
                
                if( movePoint > UIScreen.main.bounds.height - launcherView.frame.height
                    && movePoint < UIScreen.main.bounds.height - 80 ){
                    
                    let movePercent = (movePoint - ( UIScreen.main.bounds.height - 160 ) ) / 80
                    if( movePercent > 0 ){
                        self.containerView.alpha = ( 1.0 - movePercent )*1.2
                        self.blurView.alpha = movePercent
                    }
                    launcherView.frame = CGRect(x: 0, y: movePoint, width: launcherView.frame.width, height: launcherView.frame.height)
                    
                }
            }
            
            
        }else if(  triggerPanGesture.state == UIGestureRecognizer.State.ended  ){
            
            UIView.animate(withDuration: 0.2) {
                if( ( -self.launcherView.frame.height*2.0/5.0 > ( -80 + self.triggerPanGesture.translation(in: self.launcherView).y ) ) && !self.isOpen ){
                    self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                    self.containerView.alpha = 1.0
                    self.blurView.alpha = 0
                    self.isOpen = true;
                    
                    self.background.isUserInteractionEnabled = true;
                    
                }else if( UIScreen.main.bounds.height - self.launcherView.frame.height*4.0/5.0 < ( UIScreen.main.bounds.height - self.launcherView.frame.height + self.triggerPanGesture.translation(in: self.launcherView).y ) && self.isOpen ){
                    self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                    self.containerView.alpha = 0
                    self.blurView.alpha = 1
                    self.isOpen = false;
                    
                    self.background.isUserInteractionEnabled = false;
                    
                }else{
                    if( self.isOpen ){
                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.launcherView.frame.height, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                        self.containerView.alpha = 1
                        self.blurView.alpha = 0
                        
                    }else{
                        self.launcherView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 80, width: self.launcherView.frame.width, height: self.launcherView.frame.height);
                        self.containerView.alpha = 0
                        self.blurView.alpha = 1
                        
                    }
                }
            }
        }
    }
    
    
}
