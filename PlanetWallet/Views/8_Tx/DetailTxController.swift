//
//  DetailTxController.swift
//  PlanetWallet
//
//  Created by grabity on 07/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit


class DetailTxController: PlanetWalletViewController {
    
    private var planet:Planet = Planet()
    private var mainItem:MainItem = MainItem()
    private var tx:Tx = Tx()
    
    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var toAddressContainer: UIView!
    @IBOutlet var toAddressCoinImgView: PWImageView!
    @IBOutlet var toAddressLb: UILabel!
    
    @IBOutlet var toPlanetContainer: UIView!
    @IBOutlet var toPlanetNameLb: PWLabel!
    @IBOutlet var toPlanetAddressLb: PWLabel!
    @IBOutlet var toPlanetView: PlanetView!
    
    @IBOutlet var mainAmountLb: PWLabel!
    
    @IBOutlet var statusLb: PWLabel!
    @IBOutlet var amountLb: PWLabel!
    @IBOutlet var feeLb: PWLabel!
    @IBOutlet var dateLb: PWLabel!
    @IBOutlet var txIdLb: UILabel!
    
    var txHashStr: String?
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
    
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
        
        dateLb.text = tx.formattedDate()
        
        //Set Tx data
        setTxData(tx)
        
        //Set amount data
        setAmountData(tx)
        
        //Set Fee data
        setFeeData(tx)
        
        //Set TxHash data
        if let txHash = tx.tx_id {
            self.txHashStr = txHash
            txIdLb.attributedText = NSAttributedString(string: txHash,
                                                       attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
        
    }
    
    //MARK: - Private
    private func setFeeData(_ tx: Tx) {
        
        if let coinSymbol = tx.coin{
       
            if mainItem.getCoinType() == CoinType.BTC.coinType {
                
                if let fee = tx.fee { //BTC
                    feeLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: fee, item: mainItem)) \(coinSymbol)"
                    
                }
                
            }else if mainItem.getCoinType() == CoinType.ETH.coinType { // ETH
                
                if
                    let gasPriceString = tx.gasPrice,
                    let gasLimitString = tx.gasLimit,
                    let gasPrice = Decimal(string:gasPriceString),
                    let gasLimit = Decimal(string:gasLimitString) {
                    
                    let fee = ( gasPrice * gasLimit ).toString()
                    feeLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: fee, item: mainItem)) \(coinSymbol)"
                }
                
            }else if mainItem.getCoinType() == CoinType.ERC20.coinType { // ERC20
                if
                    let gasPriceString = tx.gasPrice,
                    let gasLimitString = tx.gasLimit,
                    let gasPrice = Decimal(string:gasPriceString),
                    let gasLimit = Decimal(string:gasLimitString) {
                    
                    let fee = ( gasPrice * gasLimit ).toString()
                    feeLb.text = "\(CoinNumberFormatter.full.toMaxUnit(balance: fee, item: mainItem)) \(coinSymbol)"
                }
                
            }
            
        }
       
    }
    
    private func setAmountData(_ tx: Tx) {
        
        if let value = tx.amount, let symbol = tx.symbol{
            
            let amount = CoinNumberFormatter.full.toMaxUnit(balance: value, item: mainItem)
            
            mainAmountLb.text = "\(amount) \(symbol)"
            amountLb.text = "\(amount) \(symbol)"
            
        }
        
        // imageIcon
        if mainItem.getCoinType() == CoinType.BTC.coinType {
            
            toAddressCoinImgView.image = UIImage(named: "imageTransferConfirmationBtc02")
            
        }else if mainItem.getCoinType() == CoinType.ETH.coinType {
            
            toAddressCoinImgView.image = UIImage(named: "eth")
            
        }else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            
            if let img_path = mainItem.img_path {
                toAddressCoinImgView.loadImageWithPath(Route.URL(img_path))
            }
            
        }
        
    }
    
    private func setTxData(_ tx: Tx) {
        guard let txStatus = tx.status, let txDirection = tx.type else { return }
        
        if txStatus == "confirmed" {
            statusLb.text = "transaction_status_completed_title".localized
            
            if txDirection == "received" {
                naviBar.title = "transaction_type_received_title".localized
            }
            else {
                naviBar.title = "transaction_type_sent_title".localized
            }
        }
        else if txStatus == "pending" {
            statusLb.text = "transaction_status_pending_title".localized
            naviBar.title = "transaction_status_pending_title".localized
        }
        
        //Set main display data
        if txDirection == "received" { //opponent : from
            if let fromPlanetName = tx.from_planet {
                toPlanetContainer.isHidden = false
                toAddressContainer.isHidden = true
                
                toPlanetNameLb.text = fromPlanetName
                toPlanetView.data = tx.from ?? ""
                toPlanetAddressLb.text = Utils.shared.trimAddress(tx.from ?? "")
            }
            else {
                toPlanetContainer.isHidden = true
                toAddressContainer.isHidden = false
                
                toAddressLb.text = tx.from
                toAddressLb.setColoredAddress()
            }
        }
        else if txDirection == "sent" { //opponent : to
            if let toPlanetName = tx.to_planet {
                toPlanetContainer.isHidden = false
                toAddressContainer.isHidden = true
                
                toPlanetNameLb.text = toPlanetName
                toPlanetView.data = tx.to ?? ""
                toPlanetAddressLb.text = Utils.shared.trimAddress(tx.to ?? "")
            }
            else {
                toPlanetContainer.isHidden = true
                toAddressContainer.isHidden = false
                
                toAddressLb.text = tx.to
                toAddressLb.setColoredAddress()
            }
        }
    }
    
    @IBAction func didTouchedScan(_ sender: UIButton) {
        if let urlString = tx.explorer, let url = URL(string: urlString){
            if UIApplication.shared.canOpenURL(url){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension DetailTxController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
