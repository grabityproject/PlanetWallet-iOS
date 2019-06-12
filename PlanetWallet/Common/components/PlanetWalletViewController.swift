//
//  PageViewController.swift
//  PlanetWallet
//
//  Created by grabity on 02/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetWalletViewController: UIViewController, NetworkDelegate
{
    var userInfo : Dictionary<String, Any>?
    var beforeTheme : Theme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onUpdateTheme(theme: currentTheme)
    }
    
    func viewInit() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func setData() {
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
    }
    
    
    //MARK: - Segue
    func sendAction( segue:String , userInfo : Dictionary<String, Any>? ){
        self.performSegue(withIdentifier: segue, sender: userInfo)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let passingData = sender as? Dictionary<String, Any>,
            let vc = segue.destination as? PlanetWalletViewController
        {
            vc.userInfo = passingData
        }
    }
    
    //MARK: - Theme
    var currentTheme: Theme {
        get {
            return ThemeManager.currentTheme()
        }
        set {
            ThemeManager.setTheme(newValue)
            onUpdateTheme(theme: currentTheme)
        }
    }
    
    var settingTheme: Theme {
        switch currentTheme {
        case .DARK:     return .LIGHT
        case .LIGHT:    return .DARK
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        var r : CGFloat = -1
        var g : CGFloat = -1
        var b : CGFloat = -1
        var a : CGFloat = -1
        self.view.backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        if( r+g+b+a > 0 ){
            return ( r > 0.5 && g > 0.5 && b > 0.5 ) ? .default : .lightContent
        }else{
            return .default
        }
    }
    
    func updateTheme() {
        if( beforeTheme != nil && beforeTheme != currentTheme ){
            onUpdateTheme( theme: currentTheme )
        }
        beforeTheme = currentTheme;
    }
    
    func onUpdateTheme( theme : Theme ) {
        findAllViews(view: self.view, theme: theme)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    
    func findAllViews( view:UIView, theme:Theme ){
        
        if( view is Themable ){
            (view as! Themable).setTheme(theme)
        }
        
        if( view.subviews.count > 0 ){
            view.subviews.forEach { (v) in

                findAllViews(view: v, theme: theme)
            }
        }
    }

    func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
    }
}
