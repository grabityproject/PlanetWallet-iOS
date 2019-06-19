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
    
    var inputAmount = "" {
        didSet {
            if let inputNum = Double(inputAmount) {
                displayLb.text = inputAmount
                let currency = inputNum * 1230
                fiatDisplayLb.text = "\(currency)"
                
                if inputNum > 0 {
                    submitBtn.setEnabled(true, theme: currentTheme)
                }
                else {
                    submitBtn.setEnabled(false, theme: currentTheme)
                }
            }
            else if inputAmount.isEmpty {
                inputAmount = "0"
                displayLb.text = "0"
                fiatDisplayLb.text = "0"
                submitBtn.setEnabled(false, theme: currentTheme)
            }
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        keyPad.delegate = self
        naviBar.delegate = self
        
        keyPad.shouldPoint = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleWithPlanetContainer.bringSubviewToFront(naviBar)
        self.titlePlanetView.data = titlePlanetNameLb.text!
        
        self.inputAmount = "0"
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSubmit(_ sender: UIButton) {
        
        sendAction(segue: Keys.Segue.TRANSFER_AMOUNT_TO_TRANSFER_CONFIRM, userInfo: nil)
    }
    
}

extension TransferAmountController: NumberPadDelegate {
    func didTouchedDelete() {
        self.inputAmount = String(inputAmount.dropLast())
    }
    
    func didTouchedNumberPad(_ num: String) {
        if let _ = Int(num) {
            if inputAmount == "0" {
                inputAmount = num
            }
            else {
                self.inputAmount += num
            }
        }
        else {
            if inputAmount.contains(".") == true { return }
            if inputAmount.isEmpty || inputAmount == "0" {
                self.inputAmount = "0."
            }
            else {
                self.inputAmount += "."
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
