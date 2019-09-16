//
//  TransferConfirmController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TransferConfirmController: PlanetWalletViewController {

    var planet:Planet = Planet()
    var mainItem:MainItem = MainItem()
    var tx:Tx = Tx()
    
    var fees:[String] = [String]()
    var transaction:Transaction?
    
    var networkTaskCount:Int = 0;
    
    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var fromLb: PWLabel!
    @IBOutlet var transferAmountLb: PWLabel!
    @IBOutlet var transactionFeeLb: PWLabel!
    
    @IBOutlet var toPlanetContainer: UIView!
    @IBOutlet var toPlanetNameLb: PWLabel!
    @IBOutlet var toPlanetAddressLb: PWLabel!
    @IBOutlet var toPlanetView: PlanetView!
    @IBOutlet var transferAmountMainLb: PWLabel!
    
    @IBOutlet var toAddressContainer: UIView!
    @IBOutlet var toAddressCoinImgView: PWImageView!
    @IBOutlet var toAddressLb: PWLabel!
    
    @IBOutlet var resetBtn: UIButton!
    @IBOutlet var gasContainer: UIView!
    @IBOutlet var slider: PWSlider!
    @IBOutlet var advancedGasContainer: UIView!
    
    @IBOutlet var confirmBtn: PWButton!
    
    var advancedGasPopup = AdvancedGasView()
    
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        advancedGasPopup.frame = CGRect(x: 0,
                                        y: SCREEN_HEIGHT,
                                        width: SCREEN_WIDTH,
                                        height: SCREEN_HEIGHT)
        advancedGasPopup.delegate = self
        self.view.addSubview(advancedGasPopup)
        
        resetBtn.isEnabled = false
        confirmBtn.isEnabled = false
        slider.isEnabled = false;
        slider.maximumValue = 0;
        slider.value = 0;
    }
    
    override func setData() {
        super.setData()
        
        guard
            let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let mainItem = userInfo[Keys.UserInfo.mainItem] as? MainItem,
            let tx = userInfo[Keys.UserInfo.tx] as? Tx else { self.navigationController?.popViewController(animated: false); return }
        
        
        // Data Binding
        self.planet = planet
        self.mainItem = mainItem
        self.tx = tx
        
        // Set Transaction
        self.transaction = Transaction(mainItem)
        transaction?.tx = tx;
        transaction?.deviceKey = DEVICE_KEY
        
        // Set Amount Value && NaviBar title
        if let amount = tx.amount, let symbol = mainItem.symbol {
            naviBar.title = String(format: "transfer_confirm_toolbar_title".localized, symbol)
            transferAmountMainLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: amount, item: mainItem)) \(symbol)"
            transferAmountLb.text = transferAmountMainLb.text
        }
        
        // planet, address check
        toPlanetContainer.isHidden = ( tx.to_planet == nil )
        toAddressContainer.isHidden = !( tx.to_planet == nil )
        
        // planet, address data Biding
        toPlanetNameLb.text = tx.to_planet
        toPlanetView.data = tx.to ?? String()
        toPlanetAddressLb.text = Utils.shared.trimAddress(tx.to ?? String())
        toAddressLb.text = tx.to
        toAddressLb.setColoredAddress()
        
        // advancedGasView data binding
        if mainItem.getCoinType() == CoinType.BTC.coinType {
            advancedGasContainer.isHidden = true
        }
        else {
            advancedGasContainer.isHidden = false
            
            advancedGasPopup.mainItem = mainItem
            if let ethAmountStr = planet.getMainItem()?.getBalance(),
                let ethAmountDec = Decimal(string: ethAmountStr)
            {
                advancedGasPopup.ethAmount = ethAmountDec
            }
        }
        
        // Bottom List View Data Binding
        fromLb.text = tx.from_planet
        if let parentItem = planet.getMainItem(), let coinSymbol = parentItem.symbol {
            transactionFeeLb.text = "- \(coinSymbol)"
        }
        
        // Get recommand fee
        if let coinItem = planet.getMainItem(), let coinSymbol = coinItem.symbol {
            Get(self).action(
                Route.URL("fee", coinSymbol ),
                requestCode: 0,
                resultCode: 0,
                data: nil,
                extraHeaders:  ["device-key":DEVICE_KEY] )
        }
        
        
        // Coin Image && nonce, utxos
        if mainItem.getCoinType() == CoinType.BTC.coinType {
            
            toAddressCoinImgView.defaultImage = UIImage(named: "imageTransferConfirmationBtc02")
            
            if let fromAddress =  tx.from{
                Get(self).action(
                    Route.URL("utxo", "list", CoinType.BTC.name, fromAddress ),
                    requestCode: 1,
                    resultCode: 0,
                    data: nil,
                    extraHeaders:["device-key":DEVICE_KEY] )
            }
            
        }else if mainItem.getCoinType() == CoinType.ETH.coinType {
            
            toAddressCoinImgView.defaultImage = UIImage(named: "eth")
            
            if let fromAddress =  tx.from{
                Get(self).action(
                    Route.URL("nonce", "ETH", fromAddress ),
                    requestCode: 2,
                    resultCode: 0,
                    data: nil,
                    extraHeaders:["device-key":DEVICE_KEY] )
            }
            
        }else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            
            if let img_path = mainItem.img_path{
                toAddressCoinImgView.loadImageWithPath(Route.URL(img_path))
            }
            
            if let fromAddress =  tx.from{
                Get(self).action(
                    Route.URL("nonce", "ETH", fromAddress ),
                    requestCode: 2,
                    resultCode: 0,
                    data: nil,
                    extraHeaders:["device-key":DEVICE_KEY] )
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION {
            if segue.destination is PinCodeCertificationController {
                (segue.destination as? PinCodeCertificationController)?.delegate = self
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedConfirm(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION,
                   userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION])
    }
    
    // MARK: Slider
    @IBAction func didChanged(_ sender: PWSlider) {
        sender.value = roundf(sender.value)
        
        let fee = fees[Int(roundf(sender.value))];
        if fee != tx.gasPrice {
            tx.gasPrice = fee
            displayEstimateFee( )
            isAvailableAmount()
        }
    }
    
    @IBAction func didTouchedAdvancedOpt(_ sender: UIButton) {
        //show Popup (Advanced Gas option)
        advancedGasPopup.show()
    }
    
    @IBAction func didTouchedResetGas(_ sender: UIButton) {
        feeViewSetting()
        self.advancedGasPopup.reset()
        
        gasContainer.isHidden = false
        resetBtn.isHidden = true
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if success , let dict = dictionary {
            
            if let isSuccess = dict["success"] as? Bool {
                
                if isSuccess{
                    networkTaskCount += 1
                    
                    if requestCode == 0 { // Fee
                        
                        if let resultData = dict["result"] as? [String:String]{
                           
                            self.fees = Array(resultData.values).sorted(by: { (s1, s2) -> Bool in
                                s1.compare(s2, options: .numeric) == .orderedAscending
                            })
                        }
                        
                    }else if requestCode == 1 { // utxos
                        
                        if let resultData = dict["result"] as? [[String:Any]]{
                            
                            var utxos = [UTXO]();
                            resultData.forEach { (item) in
                                utxos.append(UTXO(JSON: item)!)
                            }
                            self.tx.utxos = utxos
                            
                        }
                        
                    }else if requestCode == 2 { // nonce
                        
                        if let resultData = dict["result"] as? [String:Any]{
                            self.tx.nonce = resultData["nonce"] as? String
                        }
                        
                    }else if requestCode == 3 { // Tansfer
                        
                        if let resultData = dict["result"] as? [String:Any]{
                            self.tx.tx_id = resultData["txHash"] as? String
                            
                            sendAction(segue: Keys.Segue.TRANSFER_CONFIRM_TO_TX_RECEIPT,
                                       userInfo:[Keys.UserInfo.planet: planet,
                                                 Keys.UserInfo.mainItem: mainItem,
                                                 Keys.UserInfo.tx: tx])
                        }
                    }
                }
                else {
                    
                }
            }
            
            if networkTaskCount == 2 {
                feeViewSetting()
            }
        }
        else {
            print(result ?? "error in TransferConfirmController")
        }
    }
    
    func feeViewSetting(){
        if fees.count > 0 {
            slider.isEnabled = true
            slider.maximumValue = Float(fees.count) - 1.0
            slider.value = floorf( Float(fees.count) / 2.0 )
            
            resetBtn.isEnabled = true
            confirmBtn.isEnabled = true
            
            tx.gasPrice = fees[Int(floorf( Float(fees.count) / 2.0 ))]
            displayEstimateFee( )
            isAvailableAmount()
        }
    }
    
    func displayEstimateFee( ){
        if let transaction = transaction{
            let fee = transaction.estimateFee()
            if let parentItem = planet.getMainItem(), let coinSymbol = parentItem.symbol {
                transactionFeeLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: fee, item: mainItem)) \(coinSymbol)"
            }
        }
    }
    
    func isAvailableAmount() {
        guard let transaction = transaction,
            let fee = Decimal(string: transaction.estimateFee()),
            let amountOfTx = Decimal(string: tx.amount ?? "0")
            else
        {
            confirmBtn.setEnabled(false, theme: currentTheme)
            return
        }
        
        var balance: Decimal = 0
        
        if mainItem.getCoinType() == CoinType.BTC.coinType {
            
            balance = Decimal(string: mainItem.getBalance()) ?? 0
        }
        else if mainItem.getCoinType() == CoinType.ETH.coinType {
            balance = Decimal(string: mainItem.getBalance()) ?? 0
        }
        else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            if let eth = planet.getMainItem(), let ethBalance = Decimal(string: eth.getBalance()) {
                balance = ethBalance
            }
        }
        
        if fee + amountOfTx > balance {
            confirmBtn.setEnabled(false, theme: currentTheme)
        }
        else {
            confirmBtn.setEnabled(true, theme: currentTheme)
        }
        
    }
}

//MARK: - AdvancedGasViewDelegate
extension TransferConfirmController: AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: String, gasLimit: String) {
        tx.gasPrice = gasPrice
        tx.gasLimit = gasLimit
    
        displayEstimateFee()
        isAvailableAmount()
        
        gasContainer.isHidden = true
        resetBtn.isHidden = false
    }
}

//MARK: - NavigationBarDelegate
extension TransferConfirmController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - PinCodeCertificationDelegate
extension TransferConfirmController: PinCodeCertificationDelegate {
    func didTransferCertificated(_ isSuccess: Bool) {
        if isSuccess {
            self.view.isUserInteractionEnabled = false
            if let transaction = transaction{
                
                let rawTx = transaction.getRawTransaction(privateKey: planet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE))
                if rawTx.isEmpty {
                    self.view.isUserInteractionEnabled = true
                }
                if let symbol = mainItem.symbol{
                    Post(self).action(Route.URL("transfer", symbol), requestCode: 3, resultCode: 0, data: ["serializeTx":rawTx], extraHeaders: ["device-key":DEVICE_KEY])
                }
            }
        }
    }
}
