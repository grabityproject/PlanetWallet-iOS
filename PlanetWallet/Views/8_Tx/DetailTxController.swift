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
        
        var tokenIconImgPath: String?
        
        if let userInfo = userInfo,
            let transaction = userInfo[Keys.UserInfo.transaction] as? Tx,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let symbol = transaction.symbol,
            let coin = transaction.coin,
            let amountStr = transaction.amount
        {
            self.selectedPlanet = planet
            
            //Set Tx data
            setTxData(transaction)
            
            var amount = "-"
            
            if coin == CoinType.BTC.name {
                if let bitStr = CoinNumberFormatter.short.toBitString(satoshi: amountStr) {
                    amount = bitStr
                }
            }
            else if coin == CoinType.ETH.name { //include token
                if let ethStr = CoinNumberFormatter.short.toEthString(wei: amountStr) {
                    amount = ethStr
                }
            }
            
            //Set amount data
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20, let tokenImg = erc20.img_path {
                mainAmountLb.text = "\(amount) \(symbol)"
                amountLb.text = "\(amount) \(symbol)"
                tokenIconImgPath = tokenImg
            }
            else {
                mainAmountLb.text = "\(amount) \(symbol)"
                amountLb.text = "\(amount) \(symbol)"
            }
            
            if let gasFee = transaction.fee {
                feeLb.text = gasFee
            }
            else if let gasLimit = Decimal(string: transaction.gasLimit ?? "0"), let gasPrice = Decimal(string: transaction.gasPrice ?? "0") {
                feeLb.text = (gasLimit * gasPrice).description
            }
            
            if let dateStr = transaction.formattedDate() {
                dateLb.text = dateStr
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
        
        
        
        if let txHash = tx.tx_id {
            self.txHashStr = txHash
            txIdLb.attributedText = NSAttributedString(string: txHash,
                                                       attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().mainText,
                                                                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    
    @IBAction func didTouchedScan(_ sender: UIButton) {
        
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
