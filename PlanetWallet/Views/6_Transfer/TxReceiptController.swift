//
//  TxReceiptController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TxReceiptController: PlanetWalletViewController {
    
    @IBOutlet var toAddressContainer: UIView!
    @IBOutlet var toAddressCoinImgView: PWImageView!
    @IBOutlet var toAddressLb: UILabel!
    
    @IBOutlet var toPlanetContainer: UIView!
    @IBOutlet var toPlanetView: PlanetView!
    @IBOutlet var toPlanetNameLb: PWLabel!
    @IBOutlet var toPlanetAddressLb: PWLabel!
    
    @IBOutlet var mainAmountLb: PWLabel!
    
    @IBOutlet var fromPlanetNameLb: PWLabel!
    @IBOutlet var amountLb: UILabel!
    @IBOutlet var gasFeeLb: PWLabel!
    @IBOutlet var dateLb: PWLabel!
    @IBOutlet var txHashValueLb: UILabel!
    
    
    override func viewInit() {
        super.viewInit()
        
        if let userInfo = userInfo,
            let fromPlanet = userInfo[Keys.UserInfo.planet] as? Planet,
            let toPlanet = userInfo[Keys.UserInfo.toPlanet] as? Planet,
            let amount = userInfo[Keys.UserInfo.transferAmount] as? Double,
            let gasFee = userInfo[Keys.UserInfo.gasFee] as? String
        {
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20 {
                mainAmountLb.text = "\(amount) \(erc20.symbol ?? "")"
                amountLb.text = "\(amount) \(erc20.symbol ?? "")"
            }
            else {
                guard let coinType = fromPlanet.coinType else { return }
                if coinType == CoinType.BTC.coinType {
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
                }
                else if coinType == CoinType.ETH.coinType {
                    toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
                }
                
                mainAmountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
                amountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
            }
            
            if let toPlanetName = toPlanet.name {
                toPlanetContainer.isHidden = false
                toAddressContainer.isHidden = true
                
                toPlanetNameLb.text = toPlanetName
                toPlanetView.data = toPlanetName
                toPlanetAddressLb.text = Utils.shared.trimAddress(toPlanet.address ?? "")
            }
            else {
                toPlanetContainer.isHidden = true
                toAddressContainer.isHidden = false
                
                toAddressLb.text = toPlanet.address
                toAddressLb.setColoredAddress()
            }
            
            fromPlanetNameLb.text = fromPlanet.name ?? ""
            gasFeeLb.text = gasFee
            dateLb.text = Utils.shared.getStringFromDate(Date(), format: .yyyyMMddHHmmss)
            txHashValueLb.attributedText = NSAttributedString(string: "0x1507f1c7fba98b4ab985a4de07fd476920009a94401641b68249deec0f077cf7",
                                                              attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                           NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedOK(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedExport(_ sender: UIButton) {
        
    }
    
    //MARK: - Private
    private func dismiss() {
        sendAction(segue: Keys.Segue.MAIN_UNWIND, userInfo: nil)
    }
    
}
