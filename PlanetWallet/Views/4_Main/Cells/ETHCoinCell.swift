//
//  ETHCoinCell.swift
//  PlanetWallet
//
//  Created by grabity on 20/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ETHCoinCell: PWTableCell {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var coinIconImgView: PWImageView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var balanceLb: PWLabel!
    
    public var erc20: ERC20? {
        didSet {
            guard let erc20 = self.erc20 else { return }
            
            if let iconPath = erc20.img_path {
                coinIconImgView.loadImageWithPath(Route.URL(iconPath))
            }
            
            if let balance = erc20.balance {
                if balance == "" {
                    balanceLb.text = "0"
                }
                else {
                    balanceLb.text = CoinNumberFormatter.short.toMaxUnit(balance: balance, item: erc20)
                }
            }
            else {
                balanceLb.text = "0"
            }
            
            coinLb.text = erc20.symbol
        }
    }
    
    public var eth: ETH? {
        didSet {
            guard let eth = self.eth else { return }
            coinIconImgView.image = eth.iconImg
            
            if eth.balance == "" {
                balanceLb.text = "0"
            }
            else {
                balanceLb.text = CoinNumberFormatter.short.toMaxUnit(balance: eth.balance, coinType: CoinType.ETH)
            }
            
            coinLb.text = eth.symbol
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("ETHCoinCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }
    
}
