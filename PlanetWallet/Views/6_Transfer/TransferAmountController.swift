//
//  TransferAmountController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TransferAmountController: PlanetWalletViewController {
    
    var fromPlanet: Planet?
    var toPlanet: Planet?
    var erc20: ERC20?
    
    var availableBalance: Double = 0.0 {
        didSet {
            if let erc20 = self.erc20, let symbol = erc20.symbol {
                self.availableAmountLb.text = "\(availableBalance) \(symbol)"
            }
            else if let fromPlanet = fromPlanet, let symbol = fromPlanet.symbol {
                self.availableAmountLb.text = "\(availableBalance) \(symbol)"
            }
        }
    }
    
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
                
                if 0 <= inputNum && inputNum <= self.availableBalance {
                    //TODO: - Fiat Currency
                    let currency = inputNum * 1230
                    fiatDisplayLb.text = "\(currency)"
                    fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
                    submitBtn.setEnabled(true, theme: currentTheme)
                }
                else if inputNum == 0 {
                    inputAmount = "0"
                    displayLb.text = "0"
                    fiatDisplayLb.text = "0"
                    fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
                    submitBtn.setEnabled(false, theme: currentTheme)
                }
                else {
                    fiatDisplayLb.text = "You don’t have enough amount to send".localized
                    fiatDisplayLb.textColor = UIColor(red: 255, green: 0, blue: 80)
                    submitBtn.setEnabled(false, theme: currentTheme)
                }
            }
            else if inputAmount.isEmpty {
                inputAmount = "0"
                displayLb.text = "0"
                fiatDisplayLb.text = "0"
                fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
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
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo,
            let toPlanet = userInfo[Keys.UserInfo.toPlanet] as? Planet,
            let fromPlanet = userInfo[Keys.UserInfo.planet] as? Planet
        {
            self.fromPlanet = fromPlanet
            self.toPlanet = toPlanet
            
            //ERC20 or Coin
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20,
                let balance = Double(erc20.balance ?? "0")
            {
                self.erc20 = erc20
                availableBalance = balance
            }
            else {
                availableBalance = Double(fromPlanet.balance ?? "0") ?? 0
            }
            
            //Planet or Address
            if let toPlanetName = toPlanet.name {
                titlePlanetNameLb.text = toPlanetName
                titlePlanetView.isHidden = false
                guard let address = toPlanet.address else { return }
                titlePlanetView.data = address
            }
            else if let address = toPlanet.address {
                titlePlanetNameLb.text = Utils.shared.trimAddress(address)
                titlePlanetView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleWithPlanetContainer.bringSubviewToFront(naviBar)
        if let toAddress = toPlanet?.address {
            self.titlePlanetView.data = toAddress
        }
        
        self.inputAmount = "0"
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSubmit(_ sender: UIButton) {
        
        sendAction(segue: Keys.Segue.TRANSFER_AMOUNT_TO_TRANSFER_CONFIRM,
                   userInfo: [Keys.UserInfo.toPlanet: toPlanet as Any,
                              Keys.UserInfo.planet: fromPlanet as Any,
                              Keys.UserInfo.erc20: erc20 as Any,
                              Keys.UserInfo.transferAmount: Double(inputAmount) as Any])
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
