//
//  NicknameRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class RenamePlanetController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var nameTextfieldContainer: PWView!
    @IBOutlet var nameTextField: PWTextField!
    @IBOutlet var errLb: UILabel!
    @IBOutlet var saveBtn: PWButton!
    
    private var isValid = false {
        didSet {
            saveBtn.setEnabled(isValid, theme: settingTheme)
        }
    }

    override func viewInit() {
        super.viewInit()
        
        nameTextField.delegate = self
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    @IBAction func didTouchedSave(_ sender: UIButton) {
        
    }
    
}

extension RenamePlanetController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextfieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
//        saveBtn.setEnabled(, theme: <#T##Theme#>)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextfieldContainer.layer.borderColor = settingTheme.border.cgColor
    }
}

extension RenamePlanetController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
