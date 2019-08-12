//
//  TransferConfirmController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

class TransferConfirmController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var fromLb: PWLabel!
    @IBOutlet var transactionFeeLb: PWLabel!
    @IBOutlet var transferAmountLb: PWLabel!
    @IBOutlet var transferAmountMainLb: PWLabel!
    
    @IBOutlet var toPlanetContainer: UIView!
    @IBOutlet var toPlanetNameLb: PWLabel!
    @IBOutlet var toPlanetAddressLb: PWLabel!
    @IBOutlet var toPlanetView: PlanetView!
    
    @IBOutlet var toAddressContainer: UIView!
    @IBOutlet var toAddressCoinImgView: PWImageView!
    @IBOutlet var toAddressLb: PWLabel!
    
    @IBOutlet var resetBtn: UIButton!
    @IBOutlet var gasContainer: UIView!
    @IBOutlet var slider: PWSlider!
    
    @IBOutlet var confirmBtn: PWButton!
    
    public var isSuccessToCertification = false
    
    var coinType = CoinType.ETH
    var gas: GasInfo?
    var transactionFee: Double = 0.0 {
        didSet {
            guard let planet = self.planet else { return }
            
            if isToken {
                
                transactionFeeLb.text = "\(transactionFee.toString()) ETH"
                
                guard let ethBalanceStr = planet.balance, let ethBalance = Double(ethBalanceStr) else {
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
                if coinType.coinType == CoinType.BTC.coinType || coinType.coinType == CoinType.ETH.coinType {
                    transactionFeeLb.text = "\(transactionFee.toString()) \(coinType.defaultUnit ?? "")"
                    
                    let totalAmount = self.transferAmount + Decimal(floatLiteral: self.transactionFee)
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
    
    var gasStep: GasInfo.Step = .AVERAGE {
        didSet {
            slider.value = Float(gasStep.rawValue)

            if let transactionFee = self.gas?.getTransactionFee(step: self.gasStep),
                let gasETH: Double = transactionFee.getFeeETH() {
                self.transactionFee = gasETH
            }
        }
    }
    
    var isAdvancedGasOptions = false {
        didSet {
            if self.isAdvancedGasOptions { gasStep = .ADVANCED }
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
    
    private var isToken: Bool {
        if let _ = erc20 {
            return true
        }
        else {
            return false
        }
    }
    
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
                let balance = Decimal(string: erc20.balance ?? "0")
            {
                self.erc20 = erc20
                self.coinType = CoinType.ERC20
                self.availableAmount = balance
                
                naviBar.title = String(format: "transfer_confirm_toolbar_title".localized, erc20.name ?? "")
                
                transferAmountLb.text = "\(amount) \(erc20.symbol ?? "")"
                transferAmountMainLb.text = "\(amount) \(erc20.symbol ?? "")"
            }
            else {
                guard let coinType = fromPlanet.coinType,
                    let balance = Decimal(string: planet?.balance ?? "0") else { return }
                self.availableAmount = balance
                
                if coinType == CoinType.BTC.coinType {
                    self.coinType = CoinType.BTC
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
                }
                else if coinType == CoinType.ETH.coinType {
                    self.coinType = CoinType.ETH
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
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
    
    override func setData() {
        super.setData()
        Get(self).action(Route.URL("gas"))
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
        let step: Float = 4.0
        let roundedStepValue = round(sender.value / step) * step
        
        self.gasStep = GasInfo.Step(rawValue: Int(roundedStepValue)) ?? .AVERAGE
    }
    
    @IBAction func didTouchedAdvancedOpt(_ sender: UIButton) {
        //show Popup (Advanced Gas option)
        advancedGasPopup.show()
    }
    
    @IBAction func didTouchedResetGas(_ sender: UIButton) {
        self.gasStep = .AVERAGE
        self.isAdvancedGasOptions = !isAdvancedGasOptions
        self.advancedGasPopup.reset()
    }
    
    //MARK: - Private
    //수수료를 네트워크에서 못 가져 왔을 경우
    private func setDefaultAdvancedGasFee() {
        let transactionFee = Int(Double(GasInfo.DEFAULT_GAS_PRICE) * Double(GasInfo.DEFAULT_GAS_LIMIT_ERC20))
        if let ethTxFee: Double = Utils.shared.gweiToETH(transactionFee) {
            self.transactionFee = ethTxFee
            self.isAdvancedGasOptions = true
            self.resetBtn.isHidden = true
        }
        
    }
    
    private func sendTransaction() {
        guard let selectedPlanet = self.planet,
            let fromAddress = selectedPlanet.address,
            let toAddress = toPlanet?.address,
            let gasInfo = gas else { return }
        
        var item: MainItem?
        var coinType = ""
        var amount = ""
        var gasPrice = ""
        var gasLimit = ""
        
        if let erc20 = erc20 {
            item = erc20
            if let erc20Symbol = erc20.symbol {
                coinType = erc20Symbol
            }
        }
        else {
            if let coinSymbol = selectedPlanet.symbol {
                coinType = coinSymbol
            }
            if self.coinType.coinType == CoinType.ETH.coinType {
                item = selectedPlanet.items?.first as! ETH
            }
            else if self.coinType.coinType == CoinType.BTC.coinType {
                item = selectedPlanet.items?.first as! BTC
            }
        }
        
        guard let transferItem = item else { return }
        
        
        guard let transactionFee = gas?.getTransactionFee(step: self.gasStep) else { return }
        let amountWEI:String = Utils.shared.ethToWEI(transferAmount)
        
        amount = amountWEI
        gasPrice = "\(transactionFee.getGasPriceWEI())"
        
        if isAdvancedGasOptions {
            gasLimit = "\(gasInfo.advancedGasLimit)"
        }
        else {
            gasLimit = "\(gasInfo.getTransactionFee(step: self.gasStep).gasLimit)"
        }
        
        print("-----------Tx------------")
        print("coin Type : \(coinType)")
        print("amount of transfer : \(amountWEI)")
        print("gas price : \(transactionFee.getGasPriceWEI())")
        print("gas limit : \(gasLimit)")
        
        let tx = Transaction( transferItem )
            .deviceKey(DEVICE_KEY)
            .from(fromAddress)
            .to(toAddress)
            .value(amount)
            .gasPrice(gasPrice)
            .gasLimit(gasLimit)
        
        tx.getRawTransaction(privateKey: selectedPlanet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE), {
            (success, rawTx) in
            if success {
                print("rawTx : \(rawTx)")
                Post(self).action(Route.URL("transfer", "ETH"),
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
                let safeLow = Double(safeLowStr),
                let average = Double(averageStr),
                let fast = Double(fastStr),
                let fastest = Double(fastestStr)
            {
                var gasLimit = 100000
                if isToken == false {
                    gasLimit = 21000
                }
                self.gas = GasInfo(isToken: self.isToken,
                                   safeLow: safeLow,
                                   average: average,
                                   fast: fast,
                                   fastest: fastest,
                                   advancedGasPrice: Double(GasInfo.DEFAULT_GAS_PRICE),
                                   advancedGasLimit: gasLimit)
                self.gasStep = .AVERAGE
                self.advancedGasPopup.gasInfo = self.gas
            }
            else {
                setDefaultAdvancedGasFee()
                return
            }
        }
        else if requestCode == 100 && resultCode == 100 {   //Tx response
            
            guard let txHash = item[Keys.UserInfo.txHash], let planet = planet, let toPlanet = toPlanet else { return }
            print("Tx hash : \(txHash)")
            print("-------------------------\n")
            sendAction(segue: Keys.Segue.TRANSFER_CONFIRM_TO_TX_RECEIPT, userInfo: [Keys.UserInfo.txHash : txHash,
                                                                                    Keys.UserInfo.planet : planet,
                                                                                    Keys.UserInfo.erc20 : erc20 as Any,
                                                                                    Keys.UserInfo.transferAmount : self.transferAmount.toString(),
                                                                                    Keys.UserInfo.gasFee : gas?.getTransactionFee(step: self.gasStep).getFeeETH() as Any,
                                                                                    Keys.UserInfo.toPlanet : toPlanet])
        }
    }
}

extension TransferConfirmController: AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: Int, gasLimit: Int) {
        self.gas?.advancedGasPrice = Double(gasPrice)
        self.gas?.advancedGasLimit = gasLimit
        self.isAdvancedGasOptions = true
        if let transactionFee = gas?.getTransactionFee(step: .ADVANCED),
            let feeETH: Double = transactionFee.getFeeETH() {
            self.transactionFee = feeETH
        }
    }
}

extension TransferConfirmController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension TransferConfirmController: PinCodeCertificationDelegate {
    func didTransferCertificated(_ isSuccess: Bool) {
        if isSuccess {
            self.view.isUserInteractionEnabled = false
            self.sendTransaction()
        }
    }
}
