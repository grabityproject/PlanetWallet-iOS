//
//  BottomMenuTokenView.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import QRCode

protocol BottomMenuTokenDelegate {
    func didTouchedTokenCopy(_ addr: String)
    func didTouchedTokenSend()
}

class BottomMenuTokenView: UIView {

    var delegate: BottomMenuTokenDelegate?
    var planet: Planet?
    var erc20: ERC20?
    
    @IBOutlet var dimView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var drawerView: UIView!
    
    @IBOutlet var qrImgView: UIImageView!
    @IBOutlet var planetView: PlanetView!
    
    @IBOutlet var tokenNameLb: UILabel!
    @IBOutlet var planetNameLb: UILabel!
    @IBOutlet var addressLb: UILabel!
    
    var backgroundPanGesture : UIPanGestureRecognizer!
    
    convenience init(planet: Planet) {
        self.init(frame: CGRect.zero)
        
        self.planet = planet
    }
    
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
        
        drawerView.layer.cornerRadius = 25
        drawerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        drawerView.layer.masksToBounds = true
        
        backgroundPanGesture = UIPanGestureRecognizer(target: self, action: #selector(backgroundPanAction));
        dimView.addGestureRecognizer(backgroundPanGesture)
        
        setTheme(ThemeManager.currentTheme())
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedTransfer(_ sender: UIButton) {
        delegate?.didTouchedTokenSend()
    }
    
    @IBAction func didTouchedCopy(_ sender: UIButton) {
        if let addrStr = addressLb.text {
            delegate?.didTouchedTokenCopy(addrStr)
        }
    }
    
    
    
    //MARK: - Interface
    public func show(erc: ERC20, planet: Planet) {
        self.erc20 = erc
        self.planet = planet
        
        setUI(erc, planet: planet)
        
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
    private func setUI(_ erc20: ERC20, planet: Planet) {
        tokenNameLb.text = erc20.name
        if let planetName = planet.name, let addr = planet.address {
            planetView.data = addr
            planetNameLb.text = planetName
            addressLb.text = addr
            qrImgView.image = QRCode(addr)?.image
        }
    }
    
    private func setTheme(_ theme: Theme) {
        findAllViews(view: containerView, theme: theme)
        
        if( theme == .LIGHT ){
            drawerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            drawerView.layer.shadowOffset = CGSize(width: -2.0, height: 2.0)
            drawerView.layer.shadowRadius = 8
            drawerView.layer.shadowOpacity = 0.2
            drawerView.layer.masksToBounds = false
        }else{
            drawerView.dropShadow(radius: 0, cornerRadius: 0)
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
                }
            }
            
        }
    }
}
