//
//  CustomTokenView.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class CustomTokenController: PlanetWalletViewController {
    
    
    @IBOutlet var contractTextFieldContainer: PWView!
    @IBOutlet var contractTextfield: UITextField!
    @IBOutlet var symbolTextfield: UITextField!
    @IBOutlet var decimalsTextfield: UITextField!
    
    @IBOutlet var addTokenBtn: PWButton!
    
    @IBOutlet var errContainerView: UIView!
    @IBOutlet var errContainerConstraint: NSLayoutConstraint!
    
    private var isValidAddr = false {
        didSet {
            addTokenBtn.setEnabled(isValidAddr, theme: currentTheme)
            
            if isValidAddr {
                UIView.animate(withDuration: 1.5) {
                    self.errContainerView.isHidden = true
                    self.errContainerConstraint.isActive = true
                }
            }
            else {
                UIView.animate(withDuration: 1.5) {
                    self.errContainerView.isHidden = false
                    self.errContainerConstraint.isActive = false
                }
            }
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        contractTextfield.delegate = self
        symbolTextfield.delegate = self
        decimalsTextfield.delegate = self
    }
    
    override func setData() {
        super.setData()
    }

    //MARK: - IBAction
    @IBAction func didTouchedAddToken(_ sender: UIButton) {
        
    }
    
    //MARK: - Private
    private func isValidAddress() -> Bool {
        //TODO: - valid logic
        return true
    }
}

extension CustomTokenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard textField.tag == 0 else { return false }
        
        textField.text = ""
        addTokenBtn.setEnabled(false, theme: currentTheme)
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else { return false }
        guard textField.tag == 0 else { return true }
        
        let newLength = textFieldText.utf16.count + string.utf16.count - range.length
        
        if newLength >= 1 {
            isValidAddr = true
        }
        else {
            isValidAddr = false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            contractTextFieldContainer.layer.borderColor = currentTheme.borderPoint.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            contractTextFieldContainer.layer.borderColor = currentTheme.border.cgColor
        }
    }
}
