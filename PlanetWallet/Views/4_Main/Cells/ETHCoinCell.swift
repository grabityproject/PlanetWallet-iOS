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
    @IBOutlet var coinIconImgView: UIImageView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var amountLb: PWLabel!
    @IBOutlet var currencyLb: PWLabel!
    
    public var erc20: ERC20? {
        didSet {
            guard let erc20 = self.erc20 else { return }
            
            if let iconPath = erc20.img_path {
                coinIconImgView.downloaded(from: Route.URL(iconPath))
            }
            
            if let balance = erc20.balance {
                if balance == "" { amountLb.text = "0"}
                else { amountLb.text = balance }
                currencyLb.text = "0 USD" //TODO: - CoinMarketCap API
            }
            else {
                amountLb.text = "0"
                currencyLb.text = "0 USD"
            }
            
            coinLb.text = erc20.name
        }
    }
    
    public var eth: ETH? {
        didSet {
            guard let eth = self.eth else { return }
            coinIconImgView.image = eth.iconImg
            
            if eth.balance == "" { amountLb.text = "0"}
            else { amountLb.text = eth.balance  }
            currencyLb.text = "000000"
            
            coinLb.text = eth.name
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
