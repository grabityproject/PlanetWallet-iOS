//
//  DetailTxController.swift
//  PlanetWallet
//
//  Created by grabity on 07/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

/*
 트랜잭션 상세 보기 페이지 ( ETH, ERC20, BTC )
 
 to ( 플래닛 표현 가능/불가능 둘다 )
 from ( 플래닛 표현 가능/불가능 둘다 )
 amount
 fee
 date
 txId
 Button( Explorer로 이동 )
 */
class DetailTxController: PlanetWalletViewController {
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
    
    var selectedPlanet: Planet?
    var txHashStr: String?
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        guard let userInfo = userInfo,
            let transaction = userInfo[Keys.UserInfo.transaction] as? Tx,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet else { return }
        
        self.selectedPlanet = planet
        
        //Set Tx data
        setTxData(transaction)
        
        //Set amount data
        setAmountData(transaction)
        
        //Set Fee data
        setFeeData(transaction)
        
        //Set Date data
        if let dateStr = transaction.formattedDate() {
            dateLb.text = dateStr
        }
        
        //Set TxHash data
        if let txHash = transaction.tx_id {
            self.txHashStr = txHash
            txIdLb.attributedText = NSAttributedString(string: txHash,
                                                       attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
        
    }
    
    private func setFeeData(_ tx: Tx) {
        if let gasFee = tx.fee {
            feeLb.text = gasFee
        }
        else {
            guard let gasLimitStr = tx.gasLimit,
                let gasPriceStr = tx.gasPrice,
                let gasLimit = Decimal(string: gasLimitStr),
                let gasPrice = Decimal(string: gasPriceStr) else {
                    feeLb.text = "-"
                    return
            }
            
            feeLb.text = (gasLimit * gasPrice).description
        }
    }
    
    private func setAmountData(_ tx: Tx) {
        guard let userInfo = userInfo,
            let coin = tx.coin,
            let amountStr = tx.amount,
            let symbol = tx.symbol else { return }
        
        var amount = "-"
        var tokenIconImgPath: String?
        
        if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20, let tokenImg = erc20.img_path {
            if let shortERC20Str = CoinNumberFormatter.short.toMaxUnit(balance: amountStr, item: erc20) {
                amount = shortERC20Str
            }
            
            mainAmountLb.text = "\(amount) \(symbol)"
            amountLb.text = "\(amount) \(symbol)"
            tokenIconImgPath = tokenImg
        }
        else {
            if coin == CoinType.BTC.name {
                if let shortBTCStr = CoinNumberFormatter.short.toMaxUnit(balance: amountStr, coinType: CoinType.BTC) {
                    amount = shortBTCStr
                }
            }
            else if coin == CoinType.ETH.name { //include token
                if let shortEtherStr = CoinNumberFormatter.short.toMaxUnit(balance: amountStr, coinType: CoinType.ETH) {
                    amount = shortEtherStr
                }
            }
            mainAmountLb.text = "\(amount) \(symbol)"
            amountLb.text = "\(amount) \(symbol)"
        }
        
        //Set coin icon image
        if let tokenImgPath = tokenIconImgPath {
            toAddressCoinImgView.downloaded(from: Route.URL(tokenImgPath))
        }
        else {
            if symbol == CoinType.BTC.name {
                toAddressCoinImgView.image = ThemeManager.currentTheme().transferBTCImg
            }
            else if symbol == CoinType.ETH.name {
                toAddressCoinImgView.image = ThemeManager.currentTheme().transferETHImg
            }
        }
    }
    
    private func setTxData(_ tx: Tx) {
        guard let selectedPlanet = selectedPlanet else { return }
        
        let txStatus = TxStatus(currentPlanet: selectedPlanet, tx: tx)
        
        if txStatus.status == .CONFIRMED {
            statusLb.text = "Completed"
            
            if txStatus.direction == .RECEIVED {
                naviBar.title = "Received"
            }
            else {
                naviBar.title = "Sent"
            }
        }
        else {
            statusLb.text = "Pending"
        }
        
        //Set main display data
        if txStatus.direction == .RECEIVED { //opponent : from
            if let fromPlanetName = tx.from_planet {
                toPlanetContainer.isHidden = false
                toAddressContainer.isHidden = true
                
                toPlanetNameLb.text = fromPlanetName
                toPlanetView.data = tx.to ?? ""
                toPlanetAddressLb.text = Utils.shared.trimAddress(tx.from ?? "")
            }
            else {
                toPlanetContainer.isHidden = true
                toAddressContainer.isHidden = false
                
                toAddressLb.text = tx.to
                toAddressLb.setColoredAddress()
            }
        }
        else if txStatus.direction == .SENT { //opponent : to
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
        guard let planet = self.selectedPlanet, let coinType = planet.coinType else { return }
        if coinType == CoinType.BTC.coinType {
            return
        }
        
        var etherScanPath = ""
        guard let txHash = self.txHashStr else { return }
        
        if TESTNET {
            etherScanPath = Route.URL(txHash, baseURL: "https://ropsten.etherscan.io/tx/")
        }
        else {
            etherScanPath = Route.URL(txHash, baseURL: "https://etherscan.io/tx/")
        }
        
        guard let url = URL(string: etherScanPath),
            UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension DetailTxController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
