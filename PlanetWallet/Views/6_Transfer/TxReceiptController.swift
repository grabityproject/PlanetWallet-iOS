//
//  TxReceiptController.swift
//  PlanetWallet
//
//  Created by grabity on 18/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TxReceiptController: PlanetWalletViewController {
    
    var planet: Planet = Planet()
    var mainItem: MainItem = MainItem()
    var tx:Tx = Tx()
    
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
        
        guard
            let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let mainItem = userInfo[Keys.UserInfo.mainItem] as? MainItem,
            let tx = userInfo[Keys.UserInfo.tx] as? Tx else { self.navigationController?.popViewController(animated: false); return }
        
        self.planet = planet
        self.mainItem = mainItem
        self.tx = tx
        
        //Planet or Address
        if tx.to_planet != nil {
            toPlanetContainer.isHidden = false
            toAddressContainer.isHidden = true
            
            toPlanetNameLb.text = tx.to_planet
            toPlanetView.data = tx.to ?? ""
            toPlanetAddressLb.text = Utils.shared.trimAddress(tx.to ?? "")
        }
        else {
            toPlanetContainer.isHidden = true
            toAddressContainer.isHidden = false
            
            toAddressLb.text = tx.to
            toAddressLb.setColoredAddress()
        }
        
        // Binding Amount
        if let amount = tx.amount, let symbol = tx.symbol {
            mainAmountLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: amount, item: mainItem)) \(symbol)"
            amountLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: amount, item: mainItem)) \(symbol)"
        }
        
        // Binding Icon
        if mainItem.getCoinType() == CoinType.BTC.coinType {

            toAddressCoinImgView.defaultImage = UIImage(named: "imageTransferConfirmationBtc02")

        }
        else if mainItem.getCoinType() == CoinType.ETH.coinType {
            
            toAddressCoinImgView.defaultImage = UIImage(named: "eth")
            
        }else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            if let img_path = mainItem.img_path{
                toAddressCoinImgView.loadImageWithPath(Route.URL( img_path ))
            }
        }
        
        // Fee
        if let fee = tx.fee, let parentMainItem = planet.getMainItem(), let coinSymbol = parentMainItem.symbol{
            gasFeeLb.text = "\(CoinNumberFormatter.short.toMaxUnit(balance: fee, item: parentMainItem)) \(coinSymbol)"
        }
        
        // Set Date
        dateLb.text = tx.formattedDate()
        
        // Tx Hash
        if let txHash = tx.tx_id{
            txHashValueLb.attributedText = NSAttributedString(string: txHash,
                                                              attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                           NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
        
        
        // From Planet Name
        fromPlanetNameLb.text = planet.name
        
        // Insert saveRecentSearch()
        saveRecentSearch()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func saveRecentSearch() {
        if let keyId = planet.keyId, let symbol = mainItem.symbol {
            let toPlanet = Planet()
            toPlanet.name = tx.to_planet
            toPlanet.address = tx.to
            toPlanet.symbol = symbol
            toPlanet.coinType = mainItem.getCoinType()
            SearchStore.shared.insert(keyId: keyId, symbol: symbol, toPlanet: toPlanet)
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedOK(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func didTouchedShare(_ sender: UIButton) {
        
        if let fromName = planet.name, let amount = tx.amount, let symbol = tx.symbol, let explorer = tx.explorer {
            
            let sharingStr = String(format: "tx_receipt_shared_text".localized,
                                    fromName, CoinNumberFormatter.full.toMaxUnit(balance: amount, item: mainItem), symbol, explorer)//from, amount, symbol, explorer
            
            let ac = UIActivityViewController(activityItems: [sharingStr], applicationActivities: nil)
            present(ac, animated: true)
        }
    }
    
    @IBAction func didTouchedTxHash(_ sender: UIButton) {
        if let urlString = tx.explorer, let url = URL(string: urlString){
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK: - Private
    private func dismiss() {
        sendAction(segue: Keys.Segue.MAIN_UNWIND, userInfo: nil)
    }
    
}
