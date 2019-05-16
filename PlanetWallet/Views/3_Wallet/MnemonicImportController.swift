//
//  MnemonicImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MnemonicImportController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewInit()
        setData()
    }
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        
        pwTextfield.delegate = self
        mnemonicTextView.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    @IBAction func didTouchedInvisible(_ sender: UIButton) {
        pwTextfield.isSecureTextEntry = !pwTextfield.isSecureTextEntry
    }
    
    private func isValid(mnemonic: String) -> Bool {
        //TODO: - Logic
        return false
    }
}


extension MnemonicImportController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        
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

