//
//  PageViewController.swift
//  PlanetWallet
//
//  Created by grabity on 02/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit



class PlanetWalletViewController: UIViewController
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
//        updateTheme()
    }
    
    func viewInit() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setData() {
        
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
        return ThemeManager.currentTheme()
    }
    
    var settingTheme: Theme {
        switch currentTheme {
        case .DARK:     return .LIGHT
        case .LIGHT:    return .DARK
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch currentTheme {
        case .DARK:     return .lightContent
        case .LIGHT:    return .default
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

}
