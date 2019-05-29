//
//  RenamePlanetController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class NicknameRegistrationController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var textFieldContainer: PWView!
    @IBOutlet var saveBtn: PWButton!
    
    private var isValid = false {
        didSet {
            saveBtn.setEnabled(isValid, theme: settingTheme)
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        textField.delegate = self
    }
    
    override func setData() {
        super.setData()
    }

    //MARK: - IBAction
    @IBAction func didTouchedSave(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NicknameRegistrationController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension NicknameRegistrationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldContainer.layer.borderColor = settingTheme.border.cgColor
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
        textField.text = ""
        saveBtn.setEnabled(false, theme: settingTheme)
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

