//
//  SettingController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class SettingController: SettingPlanetWalletController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var darkThemeBtn: UIButton!
    @IBOutlet var lightThemeBtn: UIButton!
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        //Fade transition animation
        self.view.subviews.forEach { (v) in
            v.alpha = 0;
            UIView.animate(withDuration: 0.2, animations: {
                v.alpha = 1.0
            })
        }
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
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
        let dict = ["section": BoardController.Section.FAQ]
        sendAction(segue: Keys.Segue.SETTING_TO_ANNOUNCEMENTS, userInfo: dict)
    }
    
    
}

extension SettingController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.view.subviews.forEach { (v) in
                UIView.animate(withDuration: 0.3, animations: {
                    v.alpha = 0
                })
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
}
