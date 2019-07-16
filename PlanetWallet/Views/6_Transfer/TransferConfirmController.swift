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
    
    var coinType = CoinType.ETH
    var gas: GasInfo?
    var gasFee: Double = 0.0 {
        didSet {
            guard let planet = self.planet else { return }
            
            if let _ = self.erc20 {
                
                gasFeeLb.text = "\(gasFee.toString()) ETH"
                
                guard let ethBalanceStr = planet.balance, let ethBalance = Double(ethBalanceStr) else { return }
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
                    let balanceStr = planet?.balance,
                    let balance = Double(balanceStr) else { return }
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
    
    
    //MARK: - IBAction
    @IBAction func didTouchedConfirm(_ sender: UIButton) {
        let segueID = Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION
        userInfo?[Keys.UserInfo.fromSegue] = segueID
        userInfo?[Keys.UserInfo.gasFee] = gasFeeLb.text
        
        sendAction(segue: segueID, userInfo: self.userInfo)
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
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard let dict = dictionary else { return }
        
        if let resultVO = ReturnVO(JSON: dict),
            let item = resultVO.result as? Dictionary<String, Any>,
            let safeLow = item["safeLow"] as? Double,
            let average = item["standard"] as? Double,
            let fast = item["fast"] as? Double,
            let fastest = item["fastest"] as? Double
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
        if let ethStr: String = Utils.shared.gweiToETH(gasPrice) {
            self.gasFeeLb.text = "\(ethStr) ETH"
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
