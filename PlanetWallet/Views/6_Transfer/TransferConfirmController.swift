//
//  TransferConfirmController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension TransferConfirmController {
    struct Gas {
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

        public func getGas(step: Gas.Step) -> Int {
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
    var coinType = CoinType.ETH
    var gas: Gas?
    var gasStep: Gas.Step = .AVERAGE {
        didSet {
            slider.value = Float(gasStep.rawValue)
            
            if let gasGWEI = self.gas?.getGas(step: self.gasStep),
                let gasETHStr: String = Utils.shared.gweiToETH(gasGWEI),
                let defaultUnit = coinType.defaultUnit
            {
                gasFeeLb.text = "\(gasETHStr) \(defaultUnit)"
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
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20 {
                transferAmountLb.text = "\(amount) \(erc20.symbol ?? "")"
                transferAmountMainLb.text = "\(amount) \(erc20.symbol ?? "")"
            }
            else {
                guard let coinType = fromPlanet.coinType else { return }
                if coinType == CoinType.BTC.coinType {
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
                }
                else if coinType == CoinType.ETH.coinType {
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
                }
                
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
        
        self.gasStep = Gas.Step(rawValue: Int(roundedStepValue)) ?? .AVERAGE
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
            let item = resultVO.result as? Dictionary<String, Any>
        {
            
            guard let safeLow = Double(item["safeLow"] as! String) else { return }
            guard let average = Double(item["standard"] as! String) else { return }
            guard let fast = Double(item["fast"] as! String) else { return }
            guard let fastest = Double(item["fastest"] as! String) else { return }
            
            self.gas = Gas(safeLow: Int(safeLow),
                           average: Int(average),
                           fast: Int(fast),
                           fastest: Int(fastest))
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
