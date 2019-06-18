//
//  TransferAmountController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TransferAmountController: PlanetWalletViewController {
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var keyPad: NumberPad!
    @IBOutlet var availableAmountLb: UILabel!
    @IBOutlet var displayLb: UILabel!
    @IBOutlet var fiatDisplayLb: UILabel!
    @IBOutlet var submitBtn: PWButton!
    
    @IBOutlet var titleWithPlanetContainer: UIView!
    @IBOutlet var titlePlanetNameLb: PWLabel! {
        didSet {
            titlePlanetNameLb.font = Utils.shared.planetFont(style: .SEMIBOLD, size: 18)
        }
    }
    @IBOutlet var titlePlanetView: PlanetView!
    
    var amountCoin = 0.0 {
        didSet {
            displayLb.text = "\(amountCoin)"
            let currency = amountCoin * 1230
            fiatDisplayLb.text = "\(currency)"
            
            if amountCoin > 0 {
                submitBtn.setEnabled(true, theme: currentTheme)
            }
            else {
                submitBtn.setEnabled(false, theme: currentTheme)
            }
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        keyPad.delegate = self
        naviBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleWithPlanetContainer.bringSubviewToFront(naviBar)
        self.titlePlanetView.data = titlePlanetNameLb.text!
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSubmit(_ sender: UIButton) {
        
        sendAction(segue: Keys.Segue.TRANSFER_AMOUNT_TO_TRANSFER_CONFIRM, userInfo: nil)
    }
    
}

extension TransferAmountController: NumberPadDelegate {
    func didTouchedNumberPad(_ num: String) {
        if num == "" {
            self.amountCoin = 0.0
        }
        else {
            if let number = Double(num) {
                self.amountCoin = number
            }
        }
    }
    
}

extension TransferAmountController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
