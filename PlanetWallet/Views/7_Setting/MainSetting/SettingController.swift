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
    @IBOutlet var helloLb: PWLabel!
    @IBOutlet var currencyLb: PWLabel!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        updateThemeUI()
        
        //Fade transition animation
        self.view.subviews.forEach { (v) in
            v.alpha = 0;
            UIView.animate(withDuration: 0.2, animations: {
                v.alpha = 1.0
            })
        }
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedTheme(_ sender: UIButton) {
        
        updateThemeUI()
        if sender.tag == 0 {
            //DARK Theme
            currentTheme = .DARK
        }
        else {
            //Light Theme
            currentTheme = .LIGHT
        }
        
        updateThemeUI()
    }
    
    @IBAction func didTouchedFAQ(_ sender: UIButton) {
        let dict = ["section": BoardController.Section.FAQ]
        sendAction(segue: Keys.Segue.SETTING_TO_ANNOUNCEMENTS, userInfo: dict)
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
    
    
    @IBAction func didTouchedMyPlanet(_ sender: UIButton) {
        
        //TODO: - model
//        let planetInfo
        sendAction(segue: Keys.Segue.SETTING_TO_DETAIL_PLANET, userInfo: nil)
    }
    
    @IBAction func didTouchedManagePlanets(_ sender: UIButton) {
        //TODO: - model
        //        let exceptPlanet
        sendAction(segue: Keys.Segue.SETTING_TO_PLANET_MANAGEMENT, userInfo: nil)
    }
    
    //MARK: - Private
    private func updateThemeUI() {
        switch currentTheme {
        case .DARK:
            darkThemeBtn.layer.borderColor = settingTheme.errorText.cgColor
            lightThemeBtn.layer.borderColor = settingTheme.border.cgColor
        case .LIGHT:
            darkThemeBtn.layer.borderColor = settingTheme.border.cgColor
            lightThemeBtn.layer.borderColor = settingTheme.errorText.cgColor
        }
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
