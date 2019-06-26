//
//  PlanetManagementController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetManagementController: PlanetWalletViewController {

    private let cellID = "planetcell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var naviBar: NavigationBar!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        tableView.register(PlanetCell.self, forCellReuseIdentifier: cellID)
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }

}

extension PlanetManagementController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! PlanetCell
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendAction(segue: Keys.Segue.PLANET_MANAGEMENT_TO_DETAIL_PLANET, userInfo: nil)
    }
}

extension PlanetManagementController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            let segueID = Keys.Segue.PLANET_MANAGEMENT_TO_WALLET_ADD
            sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
//            let importWalletVC = UIStoryboard(name: "3_Wallet", bundle: nil).instantiateViewController(withIdentifier: "WalletAddController")
//            self.navigationController?.pushViewController(importWalletVC, animated: true)
        }
    }
}
