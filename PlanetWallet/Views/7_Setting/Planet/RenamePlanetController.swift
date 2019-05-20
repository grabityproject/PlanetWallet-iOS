//
//  NicknameRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class RenamePlanetController: SettingPlanetWalletController {

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

    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        nameTextField.delegate = self
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSave(_ sender: UIButton) {
        //TODO: - Logic
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RenamePlanetController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextfieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextfieldContainer.layer.borderColor = settingTheme.border.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else { return false }
        
        let newLength = textFieldText.utf16.count + string.utf16.count - range.length
        
        if newLength >= 1 {
            isValid = true
        }
        else {
            isValid = false
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameTextField.text = ""
        saveBtn.setEnabled(false, theme: settingTheme)
        nameTextField.resignFirstResponder()
        return false
    }
}

extension RenamePlanetController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
