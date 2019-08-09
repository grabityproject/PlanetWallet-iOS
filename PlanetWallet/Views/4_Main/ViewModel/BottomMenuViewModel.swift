//
//  BottomMenuViewModel.swift
//  PlanetWallet
//
//  Created by grabity on 08/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

class BottomMenuViewModel {
    var currentIdx = 0
    var items: [MainItem]!
    
    var symbolText = ""
    var balance = ""
    var coinImgPath = ""
    
    var tokenType: TokenType?
    
    init(planet: Planet) {
        
        guard let coinType = planet.coinType, let balance = planet.balance else { return }
        
        if coinType == CoinType.BTC.coinType {
            self.tokenType = nil
            self.symbolText = "BTC"
            self.balance = balance
            
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "tokenIconBTC.png"
                self.coinImgPath = resourcePath + "/" + imgName
            }
        }
        else {
            if let items = planet.items {
                self.items = items
                filterItems()
            }
            
            self.tokenType = .ETH
            self.symbolText = "ETH"
            self.balance = balance
            
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "tokenIconETH.png"
                self.coinImgPath = resourcePath + "/" + imgName
            }
        }
    }
    
    func didSwitched() {
        if items.isEmpty { return }
        
        guard let item = switchItem() else {
            self.symbolText = ""
            self.balance = ""
            self.coinImgPath = ""
            return
        }
        
        if let eth = item as? ETH {
            self.tokenType = .ETH
            self.symbolText = eth.symbol
            self.balance = eth.balance
            
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "tokenIconETH.png"
                self.coinImgPath = resourcePath + "/" + imgName
            }
        }
        else if let erc20 = item as? ERC20, let symbol = erc20.symbol, let balance = erc20.balance, let imgPath = erc20.img_path {
            self.tokenType = .ERC20(erc20)
            self.symbolText = symbol
            self.balance = balance
            self.coinImgPath = imgPath
        }
    }
    
    var filteredItems: [MainItem]?
    
    private func filterItems() {
        filteredItems = items.filter({ (item) -> Bool in
            if let _ = item as? ETH {
                return true
            }
            else if let erc20 = item as? ERC20, let balanceStr = erc20.balance, let balance = Double(balanceStr) {
                if balance > 0 {
                    return true
                }
            }
            return false
        })
    }
    
    private func switchItem() -> MainItem? {
        
        guard let filteredItems = filteredItems else { return nil }
        
        currentIdx += 1
        if currentIdx >= filteredItems.count {
            currentIdx = 0
        }
        
        return filteredItems[currentIdx]
    }

}
