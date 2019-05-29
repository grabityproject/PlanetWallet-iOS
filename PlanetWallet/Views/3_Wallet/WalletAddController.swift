//
//  WalletAddController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class WalletAddController: PlanetWalletViewController {
    
    @IBOutlet var closeBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = userInfo?["segue"] {
            closeBtn.isHidden = false
        }
        else {
            closeBtn.isHidden = true
        }
    }
    
    @IBAction func didTouchedCreatePlanet(_ sender: UIButton) {
        
        //popup
        let popup = PopupUniverse()
        popup.show(controller: self)
        popup.handler = { [weak self] (universe) in
            guard let strongSelf = self else { return }
            popup.dismiss()
            
            strongSelf.sendAction(segue: Keys.Segue.WALLET_ADD_TO_PALNET_GENERATE, userInfo: ["universe" : universe.description()])
        }
    }
    
    @IBAction func didTouchedImportPlanet(_ sender: UIButton) {
        
        let importPlanetController = UIStoryboard(name: "3_Wallet", bundle: nil).instantiateViewController(withIdentifier: "WalletImportController")
        self.presentDetail(importPlanetController)
    }
    
    @IBAction func didTouchedCloseBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
