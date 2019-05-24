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
        
        addTokenBtn.setEnabled(isValidAddress(), theme: currentTheme)
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if contractTextfield.text!.count > 1 {
            isValidAddr = false
        }
        else {
            isValidAddr = true
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
