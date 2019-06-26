//
//  TransferConfirmController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension TransferConfirmController {
    enum GasStep: Int {
        case SAFE_LOW = 0
        case AVERAGE = 4
        case FAST = 8
        case FASTEST = 12
        
        func getGasGWEI() -> Int {
            var gasGWEI = 0
            //TODO: - Gas station API
            
            switch self {
            case .SAFE_LOW:     gasGWEI = 10
            case .AVERAGE:      gasGWEI = 20
            case .FAST:         gasGWEI = 100
            case .FASTEST:      gasGWEI = 150
            }
            
            return gasGWEI
        }
    }
}

class TransferConfirmController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var fromLb: PWLabel!
    @IBOutlet var gasFeeLb: PWLabel!
    @IBOutlet var transferAmountLb: PWLabel!
    @IBOutlet var transferAmountMainLb: PWLabel!
    
    @IBOutlet var toPlanetNameLb: PWLabel!
    @IBOutlet var toPlanetAddressLb: PWLabel!
    @IBOutlet var toPlanetView: PlanetView!
    
    
    @IBOutlet var resetBtn: UIButton!
    @IBOutlet var gasContainer: UIView!
    @IBOutlet var slider: PWSlider!
    var coinType: UniverseType = .ETH
    var gasStep: GasStep = .AVERAGE {
        didSet {
            slider.value = Float(gasStep.rawValue)
            let gwei = self.gasStep.getGasGWEI()
            if let ethStr: String = Utils.shared.gweiToETH(gwei) {
                gasFeeLb.text = "\(ethStr) \(coinType.getUnit())"
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
        
        
    }
    
    override func setData() {
        super.setData()
        
        gasStep = .AVERAGE

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
                transferAmountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
                transferAmountMainLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
            }
            
            fromLb.text = fromPlanet.name ?? ""
            
            if let toPlanetName = toPlanet.name {
                toPlanetNameLb.text = toPlanetName
                toPlanetView.data = toPlanetName
                toPlanetAddressLb.text = Utils.shared.trimAddress(toPlanet.address ?? "")
            }
            else {
                toPlanetNameLb.isHidden = true
                toPlanetView.isHidden = true
                toPlanetAddressLb.text = toPlanet.address
                toPlanetAddressLb.setColoredAddress()
            }
        }
    }
    
    
    
    //MARK: - IBAction
    @IBAction func didTouchedConfirm(_ sender: UIButton) {
        let segueID = Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION
        
        sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue : segueID])
    }
    
    @IBAction func didChanged(_ sender: PWSlider) {
        let step: Float = 4.0
        let roundedStepValue = round(sender.value / step) * step
        
        self.gasStep = GasStep(rawValue: Int(roundedStepValue)) ?? .AVERAGE
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
}

extension TransferConfirmController: AdvancedGasViewDelegate {
    func didTouchedSave(_ gas: Int, gasLimit: Int) {
        if let ethStr: String = Utils.shared.gweiToETH(gas) {
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
