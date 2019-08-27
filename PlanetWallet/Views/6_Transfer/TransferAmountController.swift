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
    
    var availableBalance: Decimal = 0.0 {
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
            displayLb.text = inputAmount
            
            if inputAmount == "0." {
                fiatDisplayLb.text = "0"
                fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
                submitBtn.setEnabled(false, theme: currentTheme)
                
                return
            }
            
            if let inputNum = Decimal(string: inputAmount) {
                if 0 < inputNum && inputNum <= self.availableBalance {
                    //TODO: - Fiat Currency
                    let currency = inputNum * 1230
                    fiatDisplayLb.text = "\(currency)"
                    fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
                    submitBtn.setEnabled(true, theme: currentTheme)
                }
                else if inputNum == 0 {
                    if inputAmount.contains("0.") { return }
                    inputAmount = "0"
                    displayLb.text = "0"
                    fiatDisplayLb.text = "0"
                    fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
                    submitBtn.setEnabled(false, theme: currentTheme)
                }
                else {
                    fiatDisplayLb.text = "transfer_amount_not_balance_title".localized
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
    
    var coinPrecision: Int?
    
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
            let fromPlanet = userInfo[Keys.UserInfo.planet] as? Planet,
            let fromPlanetName = fromPlanet.name,
            let coinTypeInt = fromPlanet.coinType
        {
            self.fromPlanet = fromPlanet
            self.toPlanet = toPlanet
            
            //Get balance
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20, let tokenSymbol = erc20.symbol, let decimals = erc20.decimals
            {
                self.erc20 = erc20
                self.coinPrecision = Int(decimals)
                
                Get(self).action(Route.URL("balance", tokenSymbol, fromPlanetName),
                                 requestCode: 0,
                                 resultCode: 0,
                                 data: nil,
                                 extraHeaders: ["device-key": DEVICE_KEY])
            }
            else {
                self.coinPrecision = CoinType.of(coinTypeInt).precision
                Get(self).action(Route.URL("balance", CoinType.of(coinTypeInt).name, fromPlanetName),
                                 requestCode: 0,
                                 resultCode: 0,
                                 data: nil,
                                 extraHeaders: ["device-key": DEVICE_KEY])
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
    
    deinit {
        print("deinit TranfserConfirmController")
        
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
        
        guard let toPlanet = toPlanet, let fromPlanet = fromPlanet else { return }
        sendAction(segue: Keys.Segue.TRANSFER_AMOUNT_TO_TRANSFER_CONFIRM,
                   userInfo: [Keys.UserInfo.toPlanet: toPlanet,
                              Keys.UserInfo.planet: fromPlanet,
                              Keys.UserInfo.erc20: erc20 as Any,
                              Keys.UserInfo.transferAmount: inputAmount])
    }
    
    
    
    //MARK: - Network
    private func handleBalanceResponse(json: [String: Any]) {
        
        if let token = erc20 {
            guard let tokenVO = ERC20(JSON: json), let balance = tokenVO.balance else { return }
            
            if let shortTokenStr = CoinNumberFormatter.full.toMaxUnit(balance: balance, item: token),
                let tokenDecimal = Decimal(string: shortTokenStr)
            {
                self.availableBalance = tokenDecimal
            }
        }
        else {
            guard let planet = Planet(JSON: json),
                let balance = planet.balance,
                let coinTypeInt = self.fromPlanet?.coinType else { return }
            
            if coinTypeInt == CoinType.BTC.coinType {
                if let shortBTCStr = CoinNumberFormatter.full.toMaxUnit(balance: balance, coinType: CoinType.BTC),
                    let btcDecimal = Decimal(string: shortBTCStr)
                {
                    self.availableBalance = btcDecimal
                }
            }
            else if coinTypeInt == CoinType.ETH.coinType {
                if let shortEtherStr = CoinNumberFormatter.full.toMaxUnit(balance: balance, coinType: CoinType.ETH),
                    let etherDecimal = Decimal(string: shortEtherStr)
                {
                    self.availableBalance = etherDecimal
                }
            }
        }
        
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        guard let dict = dictionary, let resultObj = dict["result"] as? [String:Any] else { return }
        self.handleBalanceResponse(json: resultObj)
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
                let inputAmountForCounting = inputAmount + num
                
                if let significantFractionalDecimalDigits = inputAmountForCounting.significantFractionalDecimalDigits,
                    let precision = self.coinPrecision
                {
                    if significantFractionalDecimalDigits <= precision {
                        self.inputAmount += num
                    }
                }
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
