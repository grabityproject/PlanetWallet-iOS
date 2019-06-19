//
//  PinCodeCertificationController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension PinCodeCertificationController {
    private enum From: String {
        case SPLASH, REGISTRATION, RESET, TRANSFER, MNEMONIC_EXPORT, PRIVATEKEY_EXPORT, MAIN
        
        func segueID() -> String {
            switch self {
            case .SPLASH:               return Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION
            case .REGISTRATION:         return Keys.Segue.PINCODE_REGISTRATION_TO_CERTIFICATION
            case .RESET:                return Keys.Segue.SECURITY_TO_PINCODE_CERTIFICATION
            case .TRANSFER:             return Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION
            case .MNEMONIC_EXPORT:      return Keys.Segue.MNEMONIC_EXPORT_TO_PINCODE_CERTIFICATION
            case .PRIVATEKEY_EXPORT:    return Keys.Segue.PRIVATEKEY_EXPORT_TO_PINCODE_CERTIFICATION
            case .MAIN:                 return Keys.Segue.MAIN_TO_PINCODECERTIFICATION
            }
        }
    }
}
class PinCodeCertificationController: PlanetWalletViewController {
    
    private var passwordStr = "" {
        didSet {
            pinView.setSelectedColor(passwordStr.count)
        }
    }
    
    @IBOutlet var titleLb: UILabel!
    @IBOutlet var detailLb: UILabel!
    
    @IBOutlet var pinView: PinView!
    @IBOutlet var charPad: CharPad!
    @IBOutlet var numPad: NumberPad!
    
    private var fromSegue = From.SPLASH
    
    //MARK: - Init
    override func viewInit() {
        charPad.delegate = self
        numPad.delegate = self
        
    }
    
    override func setData() {
        if let fromSegueID = userInfo?["segue"] as? String {
            if fromSegueID == From.SPLASH.segueID() {
                fromSegue = .SPLASH
            }
            else if fromSegueID == From.REGISTRATION.segueID() {
                fromSegue = .REGISTRATION
            }
            else if fromSegueID == From.RESET.segueID() {
                fromSegue = .RESET
            }
            else if fromSegueID == From.TRANSFER.segueID() {
                fromSegue = .TRANSFER
            }
            else if fromSegueID == From.MNEMONIC_EXPORT.segueID() {
                fromSegue = .MNEMONIC_EXPORT
            }
            else if fromSegueID == From.PRIVATEKEY_EXPORT.segueID() {
                fromSegue = .PRIVATEKEY_EXPORT
            }
            else if fromSegueID == From.MAIN.segueID() {
                fromSegue = .MAIN
            }
        }
    }
    
    //MARK: - Private 
    private func handleSuccessSignIn() {
        switch fromSegue {
        case .SPLASH:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_MAIN, userInfo: nil)
        case .REGISTRATION:
            let segueID = Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE
            sendAction(segue: segueID, userInfo: ["segue": segueID])
        case .RESET:
            let segueID = Keys.Segue.PINCODE_CERTIFICATION_TO_REGISTRATION
            sendAction(segue: segueID, userInfo: ["segue": segueID])
        case .MNEMONIC_EXPORT:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_MNEMONIC_EXPORT, userInfo: nil)
        case .PRIVATEKEY_EXPORT:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_PRIVATEKEY_EXPORT, userInfo: nil)
        case .TRANSFER:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_TX_RECEIPT, userInfo: nil)
        case .MAIN:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_MNEMONIC_EXPORT, userInfo: nil)
        }
        
    }
    
    private func showNumberPad(_ isNumberPad: Bool) {
        if isNumberPad {
            charPad.isHidden = true
            numPad.isHidden = false
        }
        else {
            charPad.isHidden = false
            numPad.isHidden = true
        }
    }
    
}

extension PinCodeCertificationController: NumberPadDelegate {
    func didTouchedDelete() {
        passwordStr = String(passwordStr.dropLast())
    }
    
    func didTouchedNumberPad(_ num: String) {
        if passwordStr.count == 3 {
            showNumberPad(false)
        }
        
        passwordStr += num
    }
}

extension PinCodeCertificationController: CharPadDelegate {
    func didTouchedCharPad(_ char: String) {
        guard let savedPassword: String = Utils.shared.getDefaults(for: Keys.Userdefaults.PINCODE) else { return }
        
        self.passwordStr = passwordStr + char
        if passwordStr == savedPassword {    // Success to sign in
            handleSuccessSignIn()
        }
        else {
            titleLb.text = "Code incorrect"
            titleLb.textColor = currentTheme.errorText
            detailLb.text = "Please check your code"
            detailLb.textColor = currentTheme.errorText
            
            self.passwordStr = ""
            self.charPad.resetPassword()
            
            showNumberPad(true)
        }
    }
    
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool) {
        if isBack {
            showNumberPad(true)
            passwordStr = String(passwordStr.dropLast())
        }
    }
    
    
}


