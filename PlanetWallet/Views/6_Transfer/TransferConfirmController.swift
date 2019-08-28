//
//  TransferConfirmController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TransferConfirmController: PlanetWalletViewController {

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
    
    //Transfer PinCode 인증했는지 안했는지
    public var isSuccessToCertification = false
    
    var transaction:Transaction?
    
    var coinType = CoinType.ETH.coinType
    
    var ethereumFeeInfo: EthereumFeeInfo?
    var bitcoinFeeInfo: BitcoinFeeInfo?
    
    var transactionFee: Decimal = 0.0 {
        didSet {
            guard let planet = self.planet else { return }
            
            if self.coinType == CoinType.ERC20.coinType {
                
                transactionFeeLb.text = "\(transactionFee.toString()) ETH"
                
                guard let ethBalanceStr = planet.balance, let ethBalance = Decimal(string: ethBalanceStr) else {
                    confirmBtn.setEnabled(false, theme: currentTheme)
                    return
                }
                
                if self.availableAmount >= transferAmount && ethBalance >= self.transactionFee {
                    confirmBtn.setEnabled(true, theme: currentTheme)
                }
                else {
                    confirmBtn.setEnabled(false, theme: currentTheme)
                }
            }
            else {
                if coinType == CoinType.BTC.coinType || coinType == CoinType.ETH.coinType {
                    transactionFeeLb.text = "\(transactionFee.toString()) \(planet.symbol ?? "")"
                    
                    let totalAmount = self.transferAmount + transactionFee

                    if self.availableAmount >= totalAmount {
                        confirmBtn.setEnabled(true, theme: currentTheme)
                    }
                    else {
                        confirmBtn.setEnabled(false, theme: currentTheme)
                    }
                }
            }
        }
    }
    
    var btcFeeStep: BitcoinFeeInfo.Step = .HALF_HOUR {
        didSet {
            slider.value = (100 / Float(BitcoinFeeInfo.Step.count - 1)) * Float(btcFeeStep.rawValue)
            if let feeStr = bitcoinFeeInfo?.getTransactionFee(step: self.btcFeeStep),
                let feeDecimal = Decimal(string: feeStr)
            {
                self.transactionFee = feeDecimal
            }
        }
    }
    
    var ethFeeStep: EthereumFeeInfo.Step = .AVERAGE {
        didSet {
            slider.value = (100 / Float(EthereumFeeInfo.Step.count - 1)) * Float(ethFeeStep.rawValue)
            
            if let gasFee = self.ethereumFeeInfo?.getTransactionFee(step: self.ethFeeStep),
                let gasETH = gasFee.getFeeETH() {
                
                self.transactionFee = gasETH
            }
        }
    }
    
    var isAdvancedGasOptions = false {
        didSet {
            if self.isAdvancedGasOptions { ethFeeStep = .ADVANCED }
            gasContainer.isHidden = isAdvancedGasOptions
            resetBtn.isHidden = !isAdvancedGasOptions
        }
    }
    
    var advancedGasPopup = AdvancedGasView()
    
    var planet: Planet?
    var toPlanet: Planet?
    var erc20: ERC20?
    var transferAmount: Decimal = 0.0
    var availableAmount: Decimal = 0.0
    
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
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo,
            let fromPlanet = userInfo[Keys.UserInfo.planet] as? Planet,
            let toPlanet = userInfo[Keys.UserInfo.toPlanet] as? Planet,
            let amountStr = userInfo[Keys.UserInfo.transferAmount] as? String,
            let amount = Decimal(string: amountStr)
        {
            self.planet = fromPlanet
            self.transferAmount = amount
            self.toPlanet = toPlanet
            
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20,
                let balance = Decimal(string: erc20.balance ?? "0"),
                let decimalStr = erc20.decimals,
                let decimals = Int(decimalStr)
            {
                self.erc20 = erc20
                self.coinType = CoinType.ERC20.coinType
                
                if let availableAmountStr = CoinNumberFormatter.full.convertUnit(balance: balance.toString(), from: 0, to: decimals),
                    let amountDecimal = Decimal(string: availableAmountStr) {
                    self.availableAmount = amountDecimal
                }
                
                naviBar.title = String(format: "transfer_confirm_toolbar_title".localized, erc20.name ?? "")
                
                Get(self).action(Route.URL("gas"),
                                 requestCode: 0, resultCode: 0,
                                 data: nil)
                
                toAddressCoinImgView.loadImageWithPath(Route.URL(erc20.img_path!))
                transferAmountLb.text = "\(amount) \(erc20.symbol ?? "")"
                transferAmountMainLb.text = "\(amount) \(erc20.symbol ?? "")"
            }
            else {
                guard let coinType = fromPlanet.coinType,
                    let precision = CoinType.of(coinType).precision,
                    let balance = Decimal(string: planet?.balance ?? "0") else { return }
                
                if coinType == CoinType.BTC.coinType {
                    self.coinType = CoinType.BTC.coinType
                    Get(self).action(Route.URL("fee", "BTC"),
                                     requestCode: -1, resultCode: -1,
                                     data: nil)
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
                    advancedGasContainer.isHidden = true
                }
                else if coinType == CoinType.ETH.coinType {
                    self.coinType = CoinType.ETH.coinType
                    Get(self).action(Route.URL("gas"),
                                     requestCode: 0, resultCode: 0,
                                     data: nil)
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
                    advancedGasContainer.isHidden = false
                }
                
                if let availableAmountStr = CoinNumberFormatter.full.convertUnit(balance: balance.toString(), from: 0, to: precision),
                    let amountDecimal = Decimal(string: availableAmountStr)
                {
                    self.availableAmount = amountDecimal
                }
                
                naviBar.title = String(format: "transfer_confirm_toolbar_title".localized, CoinType.of(coinType).name)
                
                transferAmountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
                transferAmountMainLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
            }
            
            fromLb.text = fromPlanet.name ?? ""
            
            if let toPlanetName = toPlanet.name {
                toPlanetContainer.isHidden = false
                toAddressContainer.isHidden = true
                
                toPlanetNameLb.text = toPlanetName
                toPlanetView.data = toPlanet.address ?? ""
                toPlanetAddressLb.text = Utils.shared.trimAddress(toPlanet.address ?? "")
            }
            else {
                toPlanetContainer.isHidden = true
                toAddressContainer.isHidden = false
                
                toAddressLb.text = toPlanet.address
                toAddressLb.setColoredAddress()
            }
        }
    }
    
    var certificationVC: PinCodeCertificationController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION {
            certificationVC = segue.destination as? PinCodeCertificationController
            certificationVC?.delegate = self
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedConfirm(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION,
                   userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION])
    }
    
    @IBAction func didChanged(_ sender: PWSlider) {
        
        if self.coinType == CoinType.BTC.coinType {
            let stepUnitValue = Float(100 / (BitcoinFeeInfo.Step.count - 1))
            guard let step = BitcoinFeeInfo.Step(rawValue: Int(round(sender.value / stepUnitValue))) else { return }
            btcFeeStep = step
        }
        else if self.coinType == CoinType.ETH.coinType || self.coinType == CoinType.ERC20.coinType {
            let stepUnitValue = Float(100 / (EthereumFeeInfo.Step.count - 1))
            guard let step = EthereumFeeInfo.Step(rawValue: Int(round(sender.value / stepUnitValue))) else { return }
            ethFeeStep = step
        }
//        self.transaction?.getFee()
        
    }
    
    @IBAction func didTouchedAdvancedOpt(_ sender: UIButton) {
        //show Popup (Advanced Gas option)
        advancedGasPopup.show()
    }
    
    @IBAction func didTouchedResetGas(_ sender: UIButton) {
        self.ethFeeStep = .AVERAGE
        self.isAdvancedGasOptions = !isAdvancedGasOptions
        self.advancedGasPopup.reset()
    }
    
    //MARK: - Private
    //수수료를 네트워크에서 못 가져 왔을 경우
    private func setDefaultAdvancedGasFee() {
        guard let gasPriceWEI = CoinNumberFormatter.full.convertUnit(balance: EthereumFeeInfo.DEFAULT_GAS_PRICE.toString(), from: .GWEI, to: .WEI),
            let defaultGasPrice = Decimal(string: gasPriceWEI) else { return }
        
        let transactionFee = (defaultGasPrice * EthereumFeeInfo.DEFAULT_GAS_LIMIT_ERC20).toString()

        if let feeEtherStr = CoinNumberFormatter.full.convertUnit(balance: transactionFee, from: .WEI, to: .ETHER),
            let feeEther = Decimal(string: feeEtherStr)
        {
            self.transactionFee = feeEther
            self.isAdvancedGasOptions = true
            self.resetBtn.isHidden = true
        }
    }
    
    private func sendTransaction() {
        
        guard let selectedPlanet = self.planet,
            let fromAddress = selectedPlanet.address,
            let toAddress = toPlanet?.address else { return }
        
        var item: MainItem?
        var symbol = ""
        var amount = ""
        var gasPrice = ""
        var gasLimit = ""
        
        if self.coinType == CoinType.ETH.coinType || self.coinType == CoinType.ERC20.coinType {
            //---- 1.Set Gas
            if let gasInfo = ethereumFeeInfo
            {
                let transactionFee = gasInfo.getTransactionFee(step: self.ethFeeStep)
                
                gasPrice = transactionFee.getGasPriceWEI()
                
                if isAdvancedGasOptions {
                    gasLimit = "\(gasInfo.advancedGasLimit)"
                }
                else {
                    gasLimit = "\(gasInfo.getTransactionFee(step: self.ethFeeStep).gasLimit)"
                }
            }
            
            //---- 2.Set Item (ETH || ERC20)
            //---- 3.Set Symbol
            //---- 4.Set Amount
            if let erc20 = erc20, let erc20Symbol = erc20.symbol {
                item = erc20
                symbol = erc20Symbol
                
                if let tokenDecimalsStr = erc20.decimals,
                    let tokenDecimals = Int(tokenDecimalsStr),
                    let amountWEI = CoinNumberFormatter.full.convertUnit(balance: transferAmount.toString(), from: tokenDecimals, to: 0) {
                    amount = amountWEI
                }
            }
            else {
                item = selectedPlanet.items?.first as! ETH
                symbol = CoinType.ETH.name
                
                if let amountWEI = CoinNumberFormatter.full.convertUnit(balance: transferAmount.toString(), from: .ETHER, to: .WEI) {
                    amount = amountWEI
                }
            }
        }
        else if self.coinType == CoinType.BTC.coinType {
            //---- 1.Set Fee
            if let fee = bitcoinFeeInfo?.halfHour {
                gasPrice = fee.toString()
            }
            //---- 2.Set Item
            item = BTC()
            //---- 3.Set Symbol
            symbol = CoinType.BTC.name
            //---- 4.Set Amount
            if let amountSatoshi = CoinNumberFormatter.full.convertUnit(balance: transferAmount.toString(), from: .BIT, to: .SATOSHI) {
                amount = amountSatoshi
            }
        }
        
        guard let transferItem = item else { return }
        
        print("-----------Tx------------")
        print("coin Type : \(symbol)")
        print("from : \(fromAddress)")
        print("to : \(toAddress)")
        print("amount of transfer : \(amount)")
        print("gas price : \(gasPrice)")
        print("gas limit : \(gasLimit)")
        
        if self.transaction == nil {
            self.transaction = Transaction( transferItem )
                .deviceKey(DEVICE_KEY)
                .from(fromAddress)
                .to(toAddress)
                .value(amount)
                .gasPrice(gasPrice)
                .gasLimit(gasLimit) //btc일때 제거
        }
        
        
        self.transaction?.getRawTransaction(privateKey: selectedPlanet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE), {
            (success, rawTx) in
            if success {
                print("rawTx : \(rawTx)")
                Post(self).action(Route.URL("transfer", symbol),
                                  requestCode: 100,
                                  resultCode: 100,
                                  data: ["serializeTx":rawTx],
                                  extraHeaders: ["device-key":DEVICE_KEY] )
            }
            else {
                print("failed to transfer Tx")
            }
        });
        
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard let dict = dictionary,
            let resultVO = ReturnVO(JSON: dict),
            let item = resultVO.result as? Dictionary<String, String> else
        {
            if requestCode == 0 && resultCode == 0 {
                setDefaultAdvancedGasFee()
            }
            print(dictionary ?? "failed to response network")
            return
        }
        
        if requestCode == 0 && resultCode == 0 {    //Gas response
            
            if let safeLowStr = item["safeLow"],
                let averageStr = item["standard"],
                let fastStr = item["fast"],
                let fastestStr = item["fastest"],
                let safeLow = Decimal(string: safeLowStr),
                let average = Decimal(string: averageStr),
                let fast = Decimal(string: fastStr),
                let fastest = Decimal(string: fastestStr)
            {
                var gasLimit: Decimal = 100000
                if self.coinType == CoinType.ETH.coinType {
                    gasLimit = 21000
                }
                self.ethereumFeeInfo = EthereumFeeInfo(isToken: self.coinType == CoinType.ERC20.coinType,
                                   safeLow: safeLow,
                                   average: average,
                                   fast: fast,
                                   fastest: fastest,
                                   advancedGasPrice: EthereumFeeInfo.DEFAULT_GAS_PRICE,
                                   advancedGasLimit: gasLimit)
                self.ethFeeStep = .AVERAGE
                self.advancedGasPopup.gasInfo = self.ethereumFeeInfo
            }
            else {
                setDefaultAdvancedGasFee()
                return
            }
        }
        else if requestCode == -1 && resultCode == -1 { //Bitcoin Fee response
            
            if let fastestStr = item["fastestFee"],
                let halfHourStr = item["halfHourFee"],
                let hourStr = item["hourFee"],
                let fastest = Decimal(string: fastestStr),
                let halfHour = Decimal(string: halfHourStr),
                let hour = Decimal(string: hourStr)
            {
                self.bitcoinFeeInfo = BitcoinFeeInfo(fastest: fastest, halfHour: halfHour, hour: hour)
                self.btcFeeStep = .HALF_HOUR
            }
        }
        else if requestCode == 100 && resultCode == 100 {   //Tx response
            
            guard let txHash = item[Keys.UserInfo.txHash], let planet = planet, let toPlanet = toPlanet else { return }
            print("Tx hash : \(txHash)")
            print("-------------------------\n")
            
            var gasPrice: String?
            
            if coinType == CoinType.BTC.coinType {
                gasPrice = bitcoinFeeInfo?.getTransactionFee(step: self.btcFeeStep)
            }
            else {
                gasPrice = ethereumFeeInfo?.getTransactionFee(step: self.ethFeeStep).getFeeETH()?.toString()
            }
            
            
            sendAction(segue: Keys.Segue.TRANSFER_CONFIRM_TO_TX_RECEIPT, userInfo: [Keys.UserInfo.txHash : txHash,
                                                                                    Keys.UserInfo.planet : planet,
                                                                                    Keys.UserInfo.erc20 : erc20 as Any,
                                                                                    Keys.UserInfo.transferAmount : self.transferAmount.toString(),
                                                                                    Keys.UserInfo.transactionFee : gasPrice as Any,
                                                                                    Keys.UserInfo.toPlanet : toPlanet])
        }
        
        
    }
}

//MARK: - AdvancedGasViewDelegate
extension TransferConfirmController: AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: Decimal, gasLimit: Decimal) {

        self.ethereumFeeInfo?.advancedGasPrice = gasPrice
        self.ethereumFeeInfo?.advancedGasLimit = gasLimit
        self.isAdvancedGasOptions = true
        if let transactionFee = ethereumFeeInfo?.getTransactionFee(step: .ADVANCED),
            let feeETH = transactionFee.getFeeETH() {
            self.transactionFee = feeETH
        }
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
            self.sendTransaction()
        }
    }
}
