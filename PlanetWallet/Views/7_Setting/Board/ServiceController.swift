//
//  ServiceController.swift
//  PlanetWallet
//
//  Created by grabity on 18/09/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ServiceController: PlanetWalletViewController {
    
    @IBOutlet var naviBar: NavigationBar!
    
    override func viewInit() {
    }
    
    override func setData() {
        naviBar.delegate = self
    }
    
    @IBAction func didTouchedCategory(_ sender: UIButton) {
        
        var boardCategory = BoardController.Category.WALLET
        
        if sender.tag == 0 {
            boardCategory = .WALLET
        }
        else if sender.tag == 1 {
            boardCategory = .PLANET
        }
        else if sender.tag == 2 {
            boardCategory = .UNIVERSE
        }
        else if sender.tag == 3 {
            boardCategory = .SECURITY
        }
        else if sender.tag == 4 {
            boardCategory = .TRANSFER
        }
        
        sendAction(segue: Keys.Segue.SERVICE_TO_BOARD, userInfo: ["section": boardCategory])
    }
    
}

extension ServiceController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
