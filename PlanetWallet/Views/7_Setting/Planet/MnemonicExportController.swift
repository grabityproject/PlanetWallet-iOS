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
        }
    }

}

extension MnemonicExportController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
