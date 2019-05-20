//
//  MnemonicImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MnemonicImportController: PlanetWalletViewController {

    @IBOutlet var pwTextfield: UITextField!
    @IBOutlet var mnemonicTextView: UITextView!
    @IBOutlet var errMsgContainerView: UIView!
    @IBOutlet var invisibleBtn: UIButton!
    @IBOutlet var continueBtn: PWButton!
    
    private var isValidMnemonic = false {
        didSet {
            if isValidMnemonic {
                continueBtn.setEnabled(true, theme: currentTheme)
                errMsgContainerView.isHidden = true
            }
            else {
                continueBtn.setEnabled(false, theme: currentTheme)
                errMsgContainerView.isHidden = false
            }
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        pwTextfield.delegate = self
        mnemonicTextView.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedInvisible(_ sender: UIButton) {
        pwTextfield.isSecureTextEntry = !pwTextfield.isSecureTextEntry
    }
    
    //MARK: - Private
    private func isValid(mnemonic: String) -> Bool {
        //TODO: - Logic
        return false
    }
}


extension MnemonicImportController: UITextFieldDelegate, UITextViewDelegate {
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
            self.isValidMnemonic = true
        }
        return true
    }
}

