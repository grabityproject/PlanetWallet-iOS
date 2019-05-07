//
//  PageViewController.swift
//  PlanetWallet
//
//  Created by grabity on 02/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

enum Theme {
    case DARK
    case LIGHT
}

class PlanetWalletViewController: UIViewController
{
    var userInfo : Dictionary<String, Any>?
    var beforeTheme : Theme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTheme( )
    }
    
    func viewInit() { }
    func setData() { }
    
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
    func updateTheme( ) {
        if( beforeTheme != nil && beforeTheme != THEME ){
            onUpdateTheme( theme: THEME )
        }
        beforeTheme = THEME;
    }
    
    func onUpdateTheme( theme : Theme ) {
        
    }

}
