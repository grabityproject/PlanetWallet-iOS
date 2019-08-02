//
//  TransferConfirmController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension TransferConfirmController {
    struct GasInfo {
        enum Step: Int {
            case SAFE_LOW = 0
            case AVERAGE = 4
            case FAST = 8
            case FASTEST = 12
        }
        
        //Network를 통해 Transaction fee를 가져오지 못했을 경우 default value
        static let DEFAULT_GAS_PRICE = 20
        static let DEFAULT_GAS_LIMIT = 100000
        
        public var safeLow: Int = 0
        public var average: Int = 0
        public var fast: Int = 0
        public var fastest: Int = 0

        public func getGas(step: GasInfo.Step) -> Int {
            switch step {
            case .SAFE_LOW:     return self.safeLow
            case .AVERAGE:      return self.average
            case .FAST:         return self.fast
            case .FASTEST:      return self.fastest
            }
        }
    }
}


class TransferConfirmController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var fromLb: PWLabel!
    @IBOutlet var gasFeeLb: PWLabel!
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
    var gasFee: Double = 0.0 {
        didSet {
            guard let planet = self.planet else { return }
            
            if let _ = self.erc20 {
                
                gasFeeLb.text = "\(gasFee.toString()) ETH"
                
                guard let ethBalanceStr = planet.balance, let ethBalance = Double(ethBalanceStr) else {
                    confirmBtn.setEnabled(false, theme: currentTheme)
                    return
                }
                
                if self.availableAmount >= transferAmount && ethBalance >= self.gasFee {
                    confirmBtn.setEnabled(true, theme: currentTheme)
                }
                else {
                    confirmBtn.setEnabled(false, theme: currentTheme)
                }
            }
            else {
                if coinType.coinType == CoinType.BTC.coinType || coinType.coinType == CoinType.ETH.coinType {
                    gasFeeLb.text = "\(gasFee.toString()) \(coinType.defaultUnit ?? "")"
                    
                    let totalAmount = self.transferAmount + self.gasFee
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

            if let gasGWEI = self.gas?.getGas(step: self.gasStep),
                let gasETH: Double = Utils.shared.gweiToETH(gasGWEI)
            {
                gasFee = gasETH
            }
        }
    }
    
    var isAdvancedGasOptions = false {
        didSet {
            gasContainer.isHidden = isAdvancedGasOptions
            resetBtn.isHidden = !isAdvancedGasOptions
        }
    }
    
    var advancedGasPopup = AdvancedGasView()
    
    var planet: Planet?
    var toPlanet: Planet?
    var erc20: ERC20?
    var transferAmount = 0.0
    var availableAmount = 0.0
    
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
            let amount = userInfo[Keys.UserInfo.transferAmount] as? Double
        {
            self.planet = fromPlanet
            self.transferAmount = amount
            self.toPlanet = toPlanet
            
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20,
                let balance = Double(erc20.balance ?? "0")
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
                    let balance = Double(planet?.balance ?? "0") else { return }
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
        let transactionFee = Int(Double(GasInfo.DEFAULT_GAS_PRICE) * Double(GasInfo.DEFAULT_GAS_LIMIT))
        if let ethTxFee: Double = Utils.shared.gweiToETH(transactionFee) {
            self.gasFee = ethTxFee
            self.isAdvancedGasOptions = true
            self.resetBtn.isHidden = true
        }
        
    }
    
    private func sendTransaction() {
        guard let selectedPlanet = self.planet,
            let fromAddress = selectedPlanet.address,
            let toAddress = toPlanet?.address else { return }
        
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
        
        print("coin Type : \(coinType)")
        guard let amountWEI:String = Utils.shared.ethToWEI(transferAmount),
            let gasPriceWEI: String = Utils.shared.ethToWEI(gasFee) else { return }
        
        print("amount of transfer : \(amountWEI)")
        amount = amountWEI
        print("gas price : \(gasPriceWEI)")
        gasPrice = gasPriceWEI
        
        if isAdvancedGasOptions {
            gasLimit = advancedGasPopup.gasLimit
        }
        else {
            gasLimit = "\(GasInfo.DEFAULT_GAS_LIMIT)"
        }
        
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
            print(rawTx)
            Post(self).action(Route.URL("transfer", "ETH"),
                              requestCode: 100,
                              resultCode: 100,
                              data: ["serializeTx":rawTx],
                              extraHeaders: ["device-key":DEVICE_KEY] );
        });
        
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard let dict = dictionary,
            let resultVO = ReturnVO(JSON: dict),
            let item = resultVO.result as? Dictionary<String, String>,
            let safeLowStr = item["safeLow"],
            let averageStr = item["standard"],
            let fastStr = item["fast"],
            let fastestStr = item["fastest"]
            else
        {
            setDefaultAdvancedGasFee()
            return
        }
        
        if let safeLow = Double(safeLowStr),
            let average = Double(averageStr),
            let fast = Double(fastStr),
            let fastest = Double(fastestStr)
        {
            self.gas = GasInfo(safeLow: Int(safeLow * Double(AdvancedGasView.DEFAULT_GAS_LIMIT)),
                               average: Int(average * Double(AdvancedGasView.DEFAULT_GAS_LIMIT)),
                               fast: Int(fast * Double(AdvancedGasView.DEFAULT_GAS_LIMIT)),
                               fastest: Int(fastest * Double(AdvancedGasView.DEFAULT_GAS_LIMIT)))
            self.gasStep = .AVERAGE
        }
    }
}

extension TransferConfirmController: AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: Int) {
        if let gasETH: Double = Utils.shared.gweiToETH(gasPrice) {
            self.gasFee = gasETH
            self.isAdvancedGasOptions = true
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
            self.sendTransaction()
        }
    }
}
