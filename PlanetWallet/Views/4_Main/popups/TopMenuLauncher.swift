//
//  TopMenuLauncher.swift
//  PlanetWallet
//
//  Created by grabity on 23/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol MenuLauncherDelegate {
    func didSelected()
}

class TopMenuLauncher: NSObject {
    
    var delegate: MenuLauncherDelegate?
    var triggerView: UIView?
    
    private let menuView: TopMenuView = {
        let view = TopMenuView()
        
        return view
    }()
    
    private let dimView = UIView()
    
    private let cellHeight: CGFloat = 55
    private let height: CGFloat = 310
    
    let settings: [String] = {
        return ["1","2","3","4"]
    }()
    
    
    
    //MARK: - Init
    convenience init(triggerView: UIView) {
        self.init()
        self.triggerView = triggerView
        
        if let window = UIApplication.shared.keyWindow {
            menuView.collectionView.dataSource = self
            menuView.collectionView.delegate = self
            
            menuView.frame = CGRect(x: 0,
                                    y: -height,
                                    width: window.frame.width,
                                    height: height)
            
            dimView.frame = window.bounds
            dimView.backgroundColor = .clear
            dimView.isHidden = true
            
            window.addSubview(dimView)
            window.addSubview(menuView)
        }
        
        configureGesture()
        setTheme(ThemeManager.currentTheme())
    }
    
    //MARK: - Interface
    @objc public func handleDismiss() {
        UIView.animate(withDuration: 0.8) {
            self.menuView.frame = CGRect(x: 0,
                                         y: -self.menuView.frame.height,
                                         width: self.menuView.frame.width,
                                         height: self.menuView.frame.height)
        }
    }
    
    //MARK: - Private
    private func configureGesture() {
        let panDownGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(handlePanDownGesture(_:)))
        let panUpGesture = UIPanGestureRecognizer(target: self,
                                                  action: #selector(handlePanUpGesture(_:)))
        let dimPanUpGesture = UIPanGestureRecognizer(target: self,
                                                  action: #selector(handlePanUpGesture(_:)))
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapGesture(_:)))
        
        triggerView?.addGestureRecognizer(tapGesture)
        triggerView?.addGestureRecognizer(panDownGesture)
        self.menuView.addGestureRecognizer(panUpGesture)
        self.dimView.addGestureRecognizer(dimPanUpGesture)
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        showMenuWithAnimation()
    }
    
    @objc private func handlePanDownGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let location = recognizer.translation(in: window)
        
        let width = window.bounds.width

        let triggerViewPositionY = triggerView!.frame.midY
        menuView.frame = CGRect(x: 0, y: location.y - height + triggerViewPositionY, width: width, height: height)
        
        let maxY = menuView.frame.maxY
        //위로 올릴지 아래로 내릴지 판단하는 기준
        let borderY = height * (2 / 5)
        
        if maxY >= height {
            menuView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }
        
        if recognizer.state == .ended {
            
            if maxY > borderY { //end gesture
                UIView.animate(withDuration: 0.25) {
                    self.menuView.frame = CGRect(x: 0, y: 0, width: width, height: self.height)
                }
                dimView.isHidden = false
            }
            else {
                UIView.animate(withDuration: 0.25) {
                    self.menuView.frame = CGRect(x: 0, y: -self.height, width: width, height: self.height)
                }
            }
        }
    }
    
    @objc private func handlePanUpGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let location = recognizer.translation(in: window)
        let width = window.bounds.width
        
        menuView.frame = CGRect(x: 0, y: location.y, width: width, height: height)
        
        let maxY = menuView.frame.maxY
        //위로 올릴지 아래로 내릴지 판단하는 기준
        let borderY = height * (4 / 5)

        if maxY >= height {
            menuView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }

        if recognizer.state == .ended {

            if maxY > borderY {
                UIView.animate(withDuration: 0.25) {
                    self.menuView.frame = CGRect(x: 0, y: 0, width: width, height: self.height)
                }
            }
            else {  //end gesture
                UIView.animate(withDuration: 0.25) {
                    self.menuView.frame = CGRect(x: 0, y: -self.height, width: width, height: self.height)
                }
                dimView.isHidden = true
            }
        }
    }
    
    private func showMenuWithAnimation() {
        //animate fade in,out
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.menuView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.menuView.frame.width,
                                         height: self.menuView.frame.height)
        }, completion: { (_) in
            self.dimView.isHidden = false
        })
    }
    
    public func setTheme(_ theme: Theme) {
        findAllViews(view: menuView, theme: theme)
        
        if( theme == .LIGHT ){
            menuView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            menuView.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            menuView.layer.shadowRadius = 8
            menuView.layer.shadowOpacity = 0.45
            menuView.layer.masksToBounds = false
        }else{
            menuView.dropShadow(radius: 0, cornerRadius: 0)
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

extension TopMenuLauncher: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuView.cellId, for: indexPath) as! TopMenuCell
        
        cell.backgroundColor = .clear
        cell.nameLb.text = settings[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        //
        //            if let window = UIApplication.shared.keyWindow {
        //                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        //            }
        //        }) { (completed: Bool) in
        //
        //            let setting = self.settings[indexPath.item]
        //            self.delegate?.didSelected()
        //            print("success to select \(setting) item")
        //        }
    }
}


