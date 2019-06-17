//
//  ETHCoinDataSource.swift
//  PlanetWallet
//
//  Created by grabity on 21/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class ETHCoinDataSource: NSObject, UITableViewDataSource {
    
    public let cellID = "ethereumCoinCell"
    var coinList: [ERCToken]? = []
    
    override init() {
        super.init()
        
        self.coinList = [ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken(), ERCToken()]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = coinList {
            return list.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ETHCoinCell
        cell.backgroundColor = .clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = ThemeManager.currentTheme().border
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
}
