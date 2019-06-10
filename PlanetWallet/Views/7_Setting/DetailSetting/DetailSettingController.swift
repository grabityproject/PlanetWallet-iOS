//
//  DetailSettingController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import LocalAuthentication

class DetailSettingController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var biometricSwitch: PWSwitch!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        biometricSwitch.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedChangePincode(_ sender: UIButton) {
        let segueID = Keys.Segue.DETAIL_SETTING_TO_PINCODE_CERTIFICATION
        sendAction(segue: segueID, userInfo: ["segue": segueID])
    }
}

extension DetailSettingController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension DetailSettingController: PWSwitchDelegate {
    func didSwitch(_ sender: Any?, isOn: Bool) {
        Utils.shared.setDefaults(for: Keys.Userdefaults.BIOMETRICS, value: isOn)
    }
}
