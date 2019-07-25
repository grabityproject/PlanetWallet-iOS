//
//  SecurityController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import LocalAuthentication

class SecurityController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var biometricSwitch: PWSwitch!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        biometricSwitch.isOn = UserDefaults.standard.bool(forKey: Keys.Userdefaults.BIOMETRICS)
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedChangePincode(_ sender: UIButton) {
        let segueID = Keys.Segue.SECURITY_TO_PINCODE_CERTIFICATION
        sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
    }
    
    @IBAction func didTouchedSwitch(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.SECURITY_TO_PINCODE_CERTIFICATION,
                   userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.BIOMETRIC_TO_PINCODE_CERTIFICATION])
    }
}

extension SecurityController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
