//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MainController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    var rippleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Ripple animation transition
        UIView.animate(withDuration: 0.65, animations: {
            self.rippleView.layer.cornerRadius = 0
            self.rippleView.bounds = CGRect(x: 25, y: 25, width: 0, height: 0)
        })
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        self.rippleView = UIView(frame: CGRect(x: 25, y: 25, width: 0, height: 0))
        rippleView.backgroundColor = settingTheme.backgroundColor
        rippleView.layer.cornerRadius = 0
        rippleView.layer.masksToBounds = true
        self.view.addSubview(rippleView)
    }
    
    override func setData() {
        super.setData()
    }
}

extension MainController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        switch sender {
        case .LEFT:
            //Ripple animation transition
            UIView.animate(withDuration: 0.65, animations: {
                self.rippleView.layer.cornerRadius = self.view.bounds.height * 2.0 * 1.4 / 2
                self.rippleView.bounds = CGRect(x: 25, y: 25, width: self.view.bounds.height * 2.0 * 1.4, height: self.view.bounds.height * 2.0 * 1.4)
            }) { (isSuccess) in
                if isSuccess {
                    //perform segue
                    self.sendAction(segue: Keys.Segue.MAIN_TO_SETTING, userInfo: nil)
                }
            }
            
        case .RIGHT:
            print("touched Right bar item")
        }
    }
}
