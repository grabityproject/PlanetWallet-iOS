//
//  PinCodeRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension PinCodeRegistrationController {
    private enum From {
        case SPLASH, CERTIFICATION
        
        func segueID() -> String {
            switch self {
            case .SPLASH:           return Keys.Segue.SPLASH_TO_PINCODE_REGISTRATION
            case .CERTIFICATION:     return Keys.Segue.PINCODE_CERTIFICATION_TO_REGISTRATION
            }
        }
    }
}

class PinCodeRegistrationController: PlanetWalletViewController {
    
    private var passwordStr = "" {
        didSet {
            pinView.setSelectedColor(passwordStr.count)
        }
    }
    
    @IBOutlet var titleLb: PWLabel!
    @IBOutlet var detailLb: PWLabel!
    @IBOutlet var pinView: PinView!
    @IBOutlet var charPad: CharPad!
    @IBOutlet var numPad: NumberPad!
    @IBOutlet var resetBtn: UIButton!
    
    private var fromSegue = From.SPLASH
    private var isConfirmedPW = false {
        didSet {
            resetBtn.isHidden = !isConfirmedPW
        }
    }
    private var pwBeforeConfirmed = ""
    
    //MARK: - Init
    override func viewInit() {
        charPad.delegate = self
        numPad.delegate = self
    }
    
    override func setData() {
        if let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String {
            if fromSegueID == From.SPLASH.segueID() {
                fromSegue = .SPLASH
            }
            else if fromSegueID == From.CERTIFICATION.segueID() {
                titleLb.text = "Change PIN Code".localized
                fromSegue = .CERTIFICATION
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedReset(_ sender: UIButton) {
        titleLb.text = "Change PIN Code".localized
        detailLb.text = "Enter the 4 digit + alphabet".localized
        passwordStr = ""
        pwBeforeConfirmed = ""
        isConfirmedPW = false
        setNumberPad(position: 0)
    }
    
    
    //MARK: - Private
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
    
    private func handleCompleteRegistration(_ pw: String) {
        
        guard isConfirmedPW else {
            titleLb.text = "Please enter your password again.".localized
            passwordStr = ""
            pwBeforeConfirmed = pw
            isConfirmedPW = true
            setNumberPad(position: 0)
            return
        }
        
        if pw == pwBeforeConfirmed {
            let passwordArr = pw.map { String($0) }
            
            switch fromSegue {
            case .SPLASH:
                if let pwData = pw.data(using: .utf8) {
                    KeyStore.shared.setValue(key: Keys.Userdefaults.PINCODE, data: Crypto.sha256(pwData), pin: passwordArr)
                    sendAction(segue: Keys.Segue.PINCODE_REGISTRATION_TO_CERTIFICATION,
                               userInfo: [Keys.UserInfo.fromSegue : Keys.Segue.PINCODE_REGISTRATION_TO_CERTIFICATION])
                }
            case .CERTIFICATION:
                
                // change pincode and db logic
                if let pwData = pw.data(using: .utf8) {
                    
                    KeyPairStore.shared.changePinCode(before: PINCODE, after: passwordArr)
                    
                    KeyStore.shared.setValue(key: Keys.Userdefaults.PINCODE, data: Crypto.sha256(pwData), pin: passwordArr)
                    PINCODE = passwordArr
                    
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
                }
            }
        }
        else {
            titleLb.text = "Code incorrect".localized
            titleLb.textColor = currentTheme.errorText
            detailLb.text = "Please check your code".localized
            detailLb.textColor = currentTheme.errorText

            self.pinView.setSelectedColor(0)
            self.charPad.resetPassword()
            self.passwordStr = ""
            
            showNumberPad(true)
        }
    }
}

extension PinCodeRegistrationController: NumberPadDelegate {
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

extension PinCodeRegistrationController: CharPadDelegate {
    func didTouchedCharPad(_ char: String) {
        passwordStr += char
        handleCompleteRegistration(passwordStr)
    }
    
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool) {
        if isBack {
            setNumberPad(position: 3)
            passwordStr = String(passwordStr.dropLast())
        }
    }
    
    private func setNumberPad(position: Int = 0) {
        pinView.setSelectedColor(position)
        showNumberPad(true)
    }
}

