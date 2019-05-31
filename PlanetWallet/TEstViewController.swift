//
//  TEstViewController.swift
//  PlanetWallet
//
//  Created by grabity on 31/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TEstViewController: UIViewController {
    
    var rippleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rippleView = UIView(frame: CGRect(x: 31,
                                               y: 31,
                                               width: 0,
                                               height: 0))
        rippleView.alpha = 0
        rippleView.backgroundColor = .black
        rippleView.layer.cornerRadius = 0
        rippleView.layer.masksToBounds = true
        self.view.addSubview(rippleView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.rippleView.backgroundColor = UIColor.black
            self.rippleView.alpha = 0
            self.rippleView.layer.cornerRadius = 0
            self.rippleView.bounds = CGRect(x: 25, y: 25, width: 0, height: 0)
        })
    }
    @IBAction func didTouched(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.rippleView.alpha = 1
            let rippleViewMaxRadius = self.view.bounds.height * 2.0 * 1.4
            self.rippleView.layer.cornerRadius = rippleViewMaxRadius / 2
            self.rippleView.bounds = CGRect(x: 31,
                                            y: 31,
                                            width: rippleViewMaxRadius,
                                            height: rippleViewMaxRadius)
        }) { (isSuccess) in
            if isSuccess {
                //perform segue
                self.performSegue(withIdentifier: Keys.Segue.MAIN_TO_SETTING, sender: nil)
            }
        }
    }
    
}
