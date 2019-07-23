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
        case BACKGROUND, SPLASH, REGISTRATION, RESET, TRANSFER, MNEMONIC_EXPORT, PRIVATEKEY_EXPORT, MAIN, BIOMETRIC
        
        func segueID() -> String {
            switch self {
            case .BACKGROUND:           return Keys.Segue.BACKGROUND_TO_FOREGROUND_PINCODE_CERTIFICATION
            case .SPLASH:               return Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION
            case .REGISTRATION:         return Keys.Segue.PINCODE_REGISTRATION_TO_CERTIFICATION
            case .RESET:                return Keys.Segue.SECURITY_TO_PINCODE_CERTIFICATION
            case .TRANSFER:             return Keys.Segue.TRANSFER_CONFIRM_TO_PINCODE_CERTIFICATION
            case .MNEMONIC_EXPORT:      return Keys.Segue.MNEMONIC_EXPORT_TO_PINCODE_CERTIFICATION
            case .PRIVATEKEY_EXPORT:    return Keys.Segue.PRIVATEKEY_EXPORT_TO_PINCODE_CERTIFICATION
            case .MAIN:                 return Keys.Segue.MAIN_TO_PINCODECERTIFICATION
            case .BIOMETRIC:            return Keys.Segue.BIOMETRIC_TO_PINCODE_CERTIFICATION
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
    
    @IBOutlet var closeImgView: PWImageView!
    @IBOutlet var closeBtn: UIButton!
    
    private var fromSegue = From.SPLASH
    
    var isBeingDismiss = false
    
    //MARK: - Init
    override func setData() {
        charPad.delegate = self
        numPad.delegate = self
        
        if let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String {
            if fromSegueID == From.BACKGROUND.segueID() {
                hideCloseBtn()
                fromSegue = .BACKGROUND
            }
            else if fromSegueID == From.SPLASH.segueID() {
                fromSegue = .SPLASH
                hideCloseBtn()
            }
            else if fromSegueID == From.REGISTRATION.segueID() {
                fromSegue = .REGISTRATION
                hideCloseBtn()
            }
            else if fromSegueID == From.RESET.segueID() {
                self.isBeingDismiss = true
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
            else if fromSegueID == From.BIOMETRIC.segueID() {
                fromSegue = .BIOMETRIC
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: Keys.Userdefaults.BIOMETRICS) &&
            fromSegue != .BIOMETRIC &&
            isBeingDismiss == false
        {
            //BIOMETRIC CERTIFICATION
            let bioAuth = BiometricManager(self)
            bioAuth.authenticateUser()
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Private
    private func hideCloseBtn() {
        closeBtn.isHidden = true
        closeImgView.isHidden = true
    }
    
    private func handleSuccessSignIn() {
        switch fromSegue {
        case .BACKGROUND:
            self.dismiss(animated: true, completion: nil)
        case .SPLASH:
            if( PlanetStore.shared.list().count == 0 ){
                let segueID = Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE
                sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
            }else{
                sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_MAIN, userInfo: nil)
            }
            
        case .REGISTRATION:
            let segueID = Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE
            sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
        case .RESET:
            let segueID = Keys.Segue.PINCODE_CERTIFICATION_TO_REGISTRATION
            sendAction(segue: segueID, userInfo: [Keys.UserInfo.fromSegue: segueID])
        case .MNEMONIC_EXPORT:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_MNEMONIC_EXPORT, userInfo: userInfo)
        case .PRIVATEKEY_EXPORT:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_PRIVATEKEY_EXPORT, userInfo: userInfo)
        case .TRANSFER:
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_TX_RECEIPT, userInfo: self.userInfo)
        case .MAIN:
            var info = userInfo
            info?[Keys.UserInfo.fromSegue] = Keys.Segue.MAIN_TO_PINCODECERTIFICATION
            sendAction(segue: Keys.Segue.PINCODE_CERTIFICATION_TO_MNEMONIC_EXPORT, userInfo: info)
        case .BIOMETRIC:
            
            if UserDefaults.standard.bool(forKey: Keys.Userdefaults.BIOMETRICS) {
                Utils.shared.setDefaults(for: Keys.Userdefaults.BIOMETRICS, value: false)
            }
            else {
                Utils.shared.setDefaults(for: Keys.Userdefaults.BIOMETRICS, value: true)
            }
            self.dismiss(animated: true, completion: nil)
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

extension PinCodeCertificationController: BiometricManagerDelegate {
    func didAuthenticated(success: Bool, key: String?, error: Error?) {
        if success {
            handleSuccessSignIn()
        }
        else {
            print("failed to auth : \(error)")
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
        self.passwordStr = passwordStr + char
        
        if let savedPassword = KeyStore.shared.getValue(key: Keys.Userdefaults.PINCODE, pin: passwordStr.map{ String($0) }),
            let inputPassword = passwordStr.data(using: .utf8){
            
            if( savedPassword.hexString == Crypto.sha256(inputPassword).hexString ){
                PINCODE = passwordStr.map{ String($0) }
                handleSuccessSignIn()
                return
            }
        }
        
        titleLb.text = "pincode_certification_code_incorrect_title".localized
        titleLb.textColor = currentTheme.errorText
        detailLb.text = "pincode_certification_sub_title_error".localized
        detailLb.textColor = currentTheme.errorText
        
        self.passwordStr = ""
        self.charPad.resetPassword()
        
        showNumberPad(true)
        
    }
    
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool) {
        if isBack {
            showNumberPad(true)
            passwordStr = String(passwordStr.dropLast())
        }
    }
    
    
}


