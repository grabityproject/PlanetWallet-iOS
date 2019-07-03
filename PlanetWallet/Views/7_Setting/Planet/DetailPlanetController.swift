//
//  DetailPlanetController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class DetailPlanetController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var hidePlanetSwitch: PWSwitch!
    @IBOutlet var mnemonicContainer: UIView!
    @IBOutlet var privateKeyContainer: UIView!
    
    @IBOutlet var universeLb: PWLabel!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var coinAddressLb: PWLabel!
    @IBOutlet var addressLb: PWLabel!
    
    @IBOutlet var planetView: PlanetView!
    
    var planet:Planet? {
        didSet {
            updatePlanetUI()
        }
    }
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePlanetUI()
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        hidePlanetSwitch.delegate = self
    }
    
    override func setData() {
        super.setData()
        if let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let pathIdx = planet.pathIndex
        {
            self.planet = planet
            if pathIdx == -1 {
                mnemonicContainer.isHidden = true
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedExportBtns(_ sender: UIButton) {
        var segueID = ""
        if sender.tag == 0 {
            segueID = Keys.Segue.MNEMONIC_EXPORT_TO_PINCODE_CERTIFICATION
        }
        else {
            segueID = Keys.Segue.PRIVATEKEY_EXPORT_TO_PINCODE_CERTIFICATION
        }
        
        if let planet = planet {
            
            sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID, Keys.UserInfo.planet:planet])
        }
    }
    
    @IBAction func didTouchedEditName(_ sender: UIButton) {
        sendAction(segue: Keys.Segue.DETAIL_PLANET_TO_RENAME_PLANET, userInfo: userInfo)
    }
    
    //MARK: - Private
    private func updatePlanetUI() {
        if let planet = planet, let name = planet.name, let address = planet.address, let type = planet.coinType, let hideStr = planet.hide
        {
            hidePlanetSwitch.isOn = hideStr == "Y"
            
            if type == CoinType.BTC.coinType {
                universeLb.text = "BTC Universe"
                coinAddressLb.text = "BTC Address"
            }
            else if type == CoinType.ETH.coinType {
                universeLb.text = "ETH Universe"
                coinAddressLb.text = "ETH Address"
            }
            
            planetNameLb.text = name
            naviBar.title = name
            planetView.data = address
            addressLb.text = address
        }
    }
}

extension DetailPlanetController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension DetailPlanetController: PWSwitchDelegate {
    func didSwitch(_ sender: Any?, isOn: Bool) {
        guard let planet = planet else { return }
        if isOn { //Hide Planet
            planet.hide = "Y"
        }
        else {
            planet.hide = "N"
        }
        
        PlanetStore.shared.update(planet)
    }
}
