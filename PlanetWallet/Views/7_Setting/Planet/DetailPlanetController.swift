//
//  DetailPlanetController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class DetailPlanetController: SettingPlanetWalletController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var hidePlanetSwitch: PWSwitch!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    @IBAction func didTouchedExportBtns(_ sender: UIButton) {
        var segueID = ""
        if sender.tag == 0 {
            segueID = Keys.Segue.MNEMONIC_EXPORT_TO_PINCODE_CERTIFICATION
        }
        else {
            segueID = Keys.Segue.PRIVATEKEY_EXPORT_TO_PINCODE_CERTIFICATION
        }
        
        sendAction(segue: segueID, userInfo: ["segue": segueID])
    }
    
}

extension DetailPlanetController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
