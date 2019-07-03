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
    
    var planet:Planet?
    
    var adapter: PlanetManageAdapter?
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        tableView.register(PlanetCell.self, forCellReuseIdentifier: cellID)
        naviBar.delegate = self
    }
    
    override func setData() {
        adapter = PlanetManageAdapter(self.tableView, [])
        adapter?.delegates.append(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    func fetchData(){
        if let userInfo = userInfo{
            self.planet = (userInfo[Keys.UserInfo.planet] as! Planet)
            
            if let planet = planet, let keyID = planet.keyId {
                var list = PlanetStore.shared.list("", false)
                
                var removeIndex = -1
                for i in 0..<list.count {
                    if list[i].keyId == keyID {
                        removeIndex = i
                        break
                    }
                }
                
                if( removeIndex >= 0 ){
                    list.remove(at: removeIndex)
                }
                adapter?.dataSetNotify(list)
            }
        }
    }

}

extension PlanetManagementController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let planet = adapter?.dataSource[indexPath.row] {
            sendAction(segue: Keys.Segue.PLANET_MANAGEMENT_TO_DETAIL_PLANET, userInfo: [Keys.UserInfo.planet: planet])
        }
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
