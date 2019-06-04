//
//  JSONImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class JSONImportController: PlanetWalletViewController {
    
    
    @IBOutlet var pwTextFieldContainer: PWView!
    @IBOutlet var textField: PWTextField!
    
    @IBOutlet var textViewContainer: PWView!
    @IBOutlet var jsonTextView: PWTextView!
    
    @IBOutlet var continueBtn: PWButton!
    @IBOutlet var errMsgContainerView: UIView!
    
    private var isValidJSON = false {
        didSet {
            updateValidUI()
        }
    }
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateValidUI()
    }
    
    override func viewInit() {
        super.viewInit()
        textField.delegate = self
        jsonTextView.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedInvisible(_ sender: UIButton) {
        textField.isSecureTextEntry = !textField.isSecureTextEntry
    }
    
    @IBAction func didTouchedContinue(_ sender: UIButton) {
        //TODO: - wallet info
        let info = ["":""]
        sendAction(segue: Keys.Segue.JSON_IMPORT_TO_PLANET_NAME, userInfo: info)
    }
    
    
    //MARK: - Private
    private func isValid(mnemonic: String) -> Bool {
        //TODO: - Logic
        return false
    }
    
    private func updateValidUI() {
        if isValidJSON {
            continueBtn.setEnabled(true, theme: currentTheme)
            errMsgContainerView.isHidden = true
        }
        else {
            continueBtn.setEnabled(false, theme: currentTheme)
            errMsgContainerView.isHidden = false
        }
    }
}

extension JSONImportController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        isValidJSON = false
        textField.resignFirstResponder()
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.border.cgColor
    }
}

extension JSONImportController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let length = textView.text.utf16.count + text.utf16.count - range.length
        if length >= 1 {
            isValidJSON = true
        }
        else {
            isValidJSON = false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewContainer.layer.borderColor = currentTheme.borderPoint.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewContainer.layer.borderColor = currentTheme.border.cgColor
    }
}
