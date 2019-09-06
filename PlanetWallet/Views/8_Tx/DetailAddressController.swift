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
    
    private var planet: Planet = Planet()
    private var mainItem:MainItem = MainItem()
    
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
        
        guard
            let userInfo = userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet,
            let mainItem = userInfo[Keys.UserInfo.mainItem] as? MainItem else { self.navigationController?.popViewController(animated: false); return }
        
        self.planet = planet
        self.mainItem = mainItem
      
        if let symbol = mainItem.symbol {
            naviBar.title = "Receive \(symbol)"
        }
        
        if let address = planet.address, let name = planet.name{
            planetNameLb.text = name
            planetView.data = address
            addressLb.text = address
            qrCodeImgView.image = QRCode(address)?.image
        }
        
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedCopy(_ sender: UIButton) {
        if let address = planet.address {
            Utils.shared.copyToClipboard(address)
            Toast(text: "main_copy_to_clipboard".localized).show()
        }
    }
    
    @IBAction func didTouchedTransfer(_ sender: UIButton) {

        sendAction(segue: Keys.Segue.DETAIL_TX_TO_TRANSFER, userInfo: [Keys.UserInfo.planet: planet,
                                                                       Keys.UserInfo.mainItem: mainItem])
        
    }
}

extension DetailAddressController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
