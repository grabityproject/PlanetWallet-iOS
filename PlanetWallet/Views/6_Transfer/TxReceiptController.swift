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
    
    
    override func setData() {
        super.setData()
        
        guard let userInfo = userInfo,
            let fromPlanet = userInfo[Keys.UserInfo.planet] as? Planet,
            let toPlanet = userInfo[Keys.UserInfo.toPlanet] as? Planet,
            let txHash = userInfo[Keys.UserInfo.txHash] as? String,
            let amount = userInfo[Keys.UserInfo.transferAmount] as? String,
            let transactionFee = userInfo[Keys.UserInfo.transactionFee] as? String else { return }
        
        var transactionSymbol = ""
        
        if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20, let symbol = erc20.symbol, let imgPath = erc20.img_path {
            mainAmountLb.text = "\(amount) \(erc20.symbol ?? "")"
            amountLb.text = "\(amount) \(erc20.symbol ?? "")"
            toAddressCoinImgView.loadImageWithPath(Route.URL(imgPath))
            transactionSymbol = symbol
        }
        else {
            guard let coinType = fromPlanet.coinType else { return }
            if coinType == CoinType.BTC.coinType {
                toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
                transactionSymbol = "BTC"
            }
            else if coinType == CoinType.ETH.coinType {
                toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
                transactionSymbol = "ETH"
            }
            
            mainAmountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
            amountLb.text = "\(amount) \(fromPlanet.symbol ?? "")"
        }
        
        if let toPlanetName = toPlanet.name {
            toPlanetContainer.isHidden = false
            toAddressContainer.isHidden = true
            
            toPlanetNameLb.text = toPlanetName
            toPlanetView.data = toPlanet.address ?? ""
            toPlanetAddressLb.text = Utils.shared.trimAddress(toPlanet.address ?? "")
            
            //Insert Search DB
            if let fromPlanetKeyId = fromPlanet.keyId {
                SearchStore.shared.insert(keyId: fromPlanetKeyId, symbol: transactionSymbol, toPlanet: toPlanet)
            }
        }
        else {
            toPlanetContainer.isHidden = true
            toAddressContainer.isHidden = false
            
            toAddressLb.text = toPlanet.address
            toAddressLb.setColoredAddress()
        }
        
        fromPlanetNameLb.text = fromPlanet.name ?? ""
        gasFeeLb.text = transactionFee
        dateLb.text = Utils.shared.getStringFromDate(Date(), format: .yyyyMMddHHmmss)
        txHashValueLb.attributedText = NSAttributedString(string: txHash,
                                                          attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                       NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedOK(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedShare(_ sender: UIButton) {
        let items = ["Transaction sharing"]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    //MARK: - Private
    private func dismiss() {
        sendAction(segue: Keys.Segue.MAIN_UNWIND, userInfo: nil)
    }
    
}
