//
//  TransferAmountController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TransferAmountController: PlanetWalletViewController {
    
    var planet: Planet = Planet()
    var mainItem: MainItem = MainItem()
    var tx:Tx = Tx()
    
    var inputAmount:String = "0"
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var keyPad: NumberPad!
    @IBOutlet var availableAmountLb: UILabel!
    @IBOutlet var displayLb: UILabel!
    @IBOutlet var fiatDisplayLb: UILabel!
    @IBOutlet var submitBtn: PWButton!
    
    @IBOutlet var titleWithPlanetContainer: UIView!
    @IBOutlet var titlePlanetView: PlanetView!
    @IBOutlet var titlePlanetNameLb: PWLabel! {
        didSet {
            titlePlanetNameLb.font = Utils.shared.planetFont(style: .SEMIBOLD, size: 18)
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
        
        guard
            let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let mainItem = userInfo[Keys.UserInfo.mainItem] as? MainItem,
            let tx = userInfo[Keys.UserInfo.tx] as? Tx else { self.navigationController?.popViewController(animated: false); return }
        
        
        self.planet = planet
        self.mainItem = mainItem
        self.tx = tx
        
        
        // bind balance
        if let symbol = mainItem.symbol{
            availableAmountLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)) \(symbol)"
        }
        
        //Planet or Address
        if let toPlanetName = tx.to_planet {
            titlePlanetNameLb.text = toPlanetName
            titlePlanetView.isHidden = false
            guard let address = planet.address else { return }
            titlePlanetView.data = address
        }
        else if let address = tx.to {
            titlePlanetNameLb.text = Utils.shared.trimAddress(address)
            titlePlanetView.isHidden = true
        }
        
        Get(self).action(Route.URL("balance", mainItem.symbol!, planet.address!),
                         requestCode: 0,
                         resultCode: 0,
                         data: nil,
                         extraHeaders: ["device-key": DEVICE_KEY])
        
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSubmit(_ sender: UIButton) {
        tx.amount = CoinNumberFormatter.full.toMinUnit(balance: inputAmount, item: mainItem)
        sendAction(segue: Keys.Segue.TRANSFER_AMOUNT_TO_TRANSFER_CONFIRM,
                   userInfo: [Keys.UserInfo.planet: planet,
                              Keys.UserInfo.mainItem: mainItem,
                              Keys.UserInfo.tx: tx])
    }
    
    
    
    //MARK: - Network
    private func handleBalanceResponse(json: [String: Any]) {
        
        
        if let balance = MainItem(JSON: json){
            
            self.mainItem.balance = balance.getBalance()
            // bind balance
            if let symbol = mainItem.symbol{
                availableAmountLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)) \(symbol)"
            }
            
        }
        
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        guard let dict = dictionary, let resultObj = dict["result"] as? [String:Any] else { return }
        self.handleBalanceResponse(json: resultObj)
    }
    
    func checkAmount(){
        
        if let amount = Decimal(string: inputAmount){
            if( amount == 0 ){
                
                submitBtn.setEnabled(false, theme: currentTheme)
                
            }else{
                
                if let balance = Decimal(string:CoinNumberFormatter.full.toMaxUnit(balance: mainItem.getBalance(), item: mainItem)){
                    if balance <= amount{
                        fiatDisplayLb.text = "transfer_amount_not_balance_title".localized
                        fiatDisplayLb.textColor = UIColor(red: 255, green: 0, blue: 80)
                        displayLb.text = inputAmount
                        submitBtn.setEnabled(false, theme: currentTheme)
                        return
                    }else{
                        submitBtn.setEnabled(true, theme: currentTheme)
                    }
                }else{
                    submitBtn.setEnabled(false, theme: currentTheme)
                }
                
            }
        }else{
            inputAmount = "0"
        }
        
        fiatDisplayLb.text = "-"
        fiatDisplayLb.textColor = UIColor(red: 170, green: 170, blue: 170)
        displayLb.text = inputAmount
    }
    
}


extension TransferAmountController: NumberPadDelegate {
   
    func didTouchedDelete() {
        self.inputAmount = String(inputAmount.dropLast())
        checkAmount()
    }
    
    func didTouchedNumberPad(_ num: String) {
        
        if let _ = Int(num) {
            
            if inputAmount == "0" { inputAmount = "" }
            
            inputAmount += num
            if( inputAmount.contains(".") ){
                
                if let inputAmountDecimal = Decimal(string: inputAmount){
                    if let precision = CoinType.of(mainItem.getCoinType()).precision{
                        if inputAmountDecimal.significantFractionalDecimalDigits > precision{
                            self.inputAmount = String(inputAmount.dropLast())
                            return
                        }
                    }else if let decimals = mainItem.decimals, let precision = Int(decimals){
                        if inputAmountDecimal.significantFractionalDecimalDigits > precision{
                            self.inputAmount = String(inputAmount.dropLast())
                            return
                        }
                    }
                }
            }
        }else {
            print(inputAmount)
            print(inputAmount.contains("."))
            if( !inputAmount.contains(".") ){
                inputAmount += num
            }
        }
        checkAmount()
    }
    
}

extension TransferAmountController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
