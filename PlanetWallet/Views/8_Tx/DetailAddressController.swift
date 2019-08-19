//
//  DetailAddressController.swift
//  PlanetWallet
//
//  Created by grabity on 19/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import QRCode

class DetailAddressController: PlanetWalletViewController {
    
    private var planet: Planet?
    private var erc20: ERC20?
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var cardContainerView: PWView!
    @IBOutlet var cardContentView: UIView!
    
    @IBOutlet var planetNameLb: UILabel!
    @IBOutlet var addressLb: UILabel!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var qrCodeImgView: UIImageView!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        
        cardContentView.layer.cornerRadius = 25
        cardContentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        cardContentView.layer.masksToBounds = true
        
        if currentTheme == .LIGHT {
            cardContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            cardContainerView.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            cardContainerView.layer.shadowRadius = 8
            cardContainerView.layer.shadowOpacity = 0.2
            cardContainerView.layer.masksToBounds = false
        }
        else {
            cardContainerView.dropShadow(radius: 0, cornerRadius: 0)
        }
    }

    override func setData() {
        super.setData()
        
        guard let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet else { return }
        
        self.planet = planet
        setPlanet(planet)
        
        if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20
        {//ERC20
            self.erc20 = erc20
            guard let symbol = erc20.symbol else { return }
            
            naviBar.title = "Received" + " " + symbol
        }
        else {//Coin
            guard let symbol = planet.symbol else { return }
            
            naviBar.title = "Received" + " "  + symbol
        }
    }
    
    //MARK: - Private
    private func setPlanet(_ planet: Planet) {
        if let planetName = planet.name, let address = planet.address {
            self.planetNameLb.text = planetName
            self.planetView.data = address
            self.addressLb.text = address
            self.qrCodeImgView.image = QRCode(address)?.image
        }
    }
    
    
    //MARK: - IBAction
    @IBAction func didTouchedCopy(_ sender: UIButton) {
        if let addr = self.planet?.address {
            Utils.shared.copyToClipboard(addr)
            Toast(text: "main_copy_to_clipboard".localized).show()
        }
    }
    
    @IBAction func didTouchedTransfer(_ sender: UIButton) {
        guard let planet = planet else { return }
        
        if let token = erc20 {
            sendAction(segue: Keys.Segue.DETAIL_TX_TO_TRANSFER, userInfo: [Keys.UserInfo.planet: planet,
                                                                           Keys.UserInfo.erc20: token])
        }
        else {
            sendAction(segue: Keys.Segue.DETAIL_TX_TO_TRANSFER, userInfo: [Keys.UserInfo.planet: planet])
        }
    }
}

extension DetailAddressController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
