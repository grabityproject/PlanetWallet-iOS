//
//  MnemonicExportController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MnemonicExportController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textView: PWTextView!
    
    var planet:Planet?
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo {
            if let planet = userInfo[Keys.UserInfo.planet] as? Planet {
                self.planet = planet
                textView.text = planet.getMnemonic(keyPairStore: KeyPairStore.shared, pinCode: PINCODE)
            }
            
            if let from = userInfo[Keys.UserInfo.fromSegue] as? String {
                if from == Keys.Segue.MAIN_TO_PINCODECERTIFICATION {
                    Utils.shared.setDefaults(for: Keys.UserInfo.shouldBackUpMnemonic, value: true)
                }
            }
        }
        
        
    }

}

extension MnemonicExportController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            //dismiss pincode certification vc
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
