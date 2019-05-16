//
//  SettingController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class SettingController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var darkThemeBtn: UIButton!
    @IBOutlet var lightThemeBtn: UIButton!
    
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
    
    @IBAction func didTouchedTheme(_ sender: UIButton) {
        
        if sender.tag == 0 {
            //DARK Theme
            darkThemeBtn.layer.borderColor = settingTheme.errorText.cgColor
            
            lightThemeBtn.layer.borderColor = settingTheme.border.cgColor
        }
        else {
            //Light Theme
            darkThemeBtn.layer.borderColor = settingTheme.border.cgColor
            
            lightThemeBtn.layer.borderColor = settingTheme.errorText.cgColor
        }
    }
    
    @IBAction func didTouchedFAQ(_ sender: UIButton) {
        let dict = ["section": NoticeFAQController.Section.FAQ]
        sendAction(segue: Keys.Segue.SETTING_TO_ANNOUNCEMENTS, userInfo: dict)
    }
    
    
}

extension SettingController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: false)
        }
    }
}
