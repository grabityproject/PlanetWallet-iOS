//
//  AccountController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension AccountController {
    private enum AccountMenu: Int {
        case NICKNAME, EMAIL, PHONE, CONNECT
    }
}
class AccountController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var nickNameLb: PWLabel!
    @IBOutlet var emailLb: PWLabel!
    @IBOutlet var phoneLb: PWLabel!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
}

extension AccountController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
