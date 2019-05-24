//
//  JSONImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class JSONImportController: PlanetWalletViewController {
    
    @IBOutlet var textField: PWTextField!
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

extension JSONImportController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // hides text views
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        else {
            //TODO: - Logic
            self.isValidJSON = true
        }
        return true
    }
}
