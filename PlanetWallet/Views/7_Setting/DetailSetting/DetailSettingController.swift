//
//  DetailSettingController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class DetailSettingController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var currencyLb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    @IBAction func didTouchedCurrency(_ sender: UIButton) {
        let popup = PopupCurrency()
        popup.show(controller: self)
        popup.handler = { [weak self](currency) in
            guard let strongSelf = self else { return }
            strongSelf.currencyLb.text = currency
            popup.dismiss()
        }
    }
    
    @IBAction func didTouchedChangePincode(_ sender: UIButton) {
        
    }
}

extension DetailSettingController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
