//
//  EmailRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class EmailRegistrationController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var textFieldContainer: PWView!
    @IBOutlet var sendBtn: PWButton!
    @IBOutlet var confirmMsgLb: UILabel!
    
    private var isValid = false {
        didSet {
            sendBtn.setEnabled(isValid, theme: settingTheme)
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
    @IBAction func didTouchedSend(_ sender: PWButton) {
        confirmMsgLb.isHidden = false
//        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Private
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
}

extension EmailRegistrationController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension EmailRegistrationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let email = textField.text {
            isValid = isValidEmailAddress(emailAddressString: email)
        }
        textFieldContainer.layer.borderColor = settingTheme.border.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else { return false }
        
        let newLength = textFieldText.utf16.count + string.utf16.count - range.length
        
        if newLength >= 1 {
            isValid = isValidEmailAddress(emailAddressString: textFieldText)
        }
        else {
            isValid = false
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        sendBtn.setEnabled(false, theme: settingTheme)
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
