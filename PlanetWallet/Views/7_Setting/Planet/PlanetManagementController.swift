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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PlanetCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }

}

extension PlanetManagementController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! PlanetCell
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension PlanetManagementController: PlanetCellDelegate {
    func didTouchedMoreBtn(indexPath: IndexPath) {
        sendAction(segue: Keys.Segue.PLANET_MANAGEMENT_TO_DETAIL_PLANET, userInfo: nil)
    }
}

extension PlanetManagementController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
