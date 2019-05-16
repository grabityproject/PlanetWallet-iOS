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
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
}

extension MnemonicExportController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
