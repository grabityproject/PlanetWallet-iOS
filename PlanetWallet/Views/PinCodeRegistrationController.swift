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
    
    private var pinCode = "" {
        didSet {
            pinView.setSelectedColor(pinCode.count)
        }
    }
    
    @IBOutlet var titleLb: PWLabel!
    @IBOutlet var detailLb: PWLabel!
    @IBOutlet var pinView: PinView!
    @IBOutlet var charPad: CharPad!
    @IBOutlet var numPad: NumberPad!
    @IBOutlet var resetBtn: UIButton!
    
    @IBOutlet var closeImgView: PWImageView!
    @IBOutlet var closeBtn: UIButton!
    
    
    private var fromSegue = From.SPLASH
    private var isOneMoreConfirmed = false {
        didSet {
            resetBtn.isHidden = !isOneMoreConfirmed
        }
    }
    private var firstPINCode = ""
    
    //MARK: - Init
    override func viewInit() {
        charPad.delegate = self
        numPad.delegate = self
    }
    
    override func setData() {
        guard let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String else { return }
        
        if fromSegueID == From.SPLASH.segueID() {
            fromSegue = .SPLASH
        }
        else if fromSegueID == From.CERTIFICATION.segueID() {
            fromSegue = .CERTIFICATION
            showCloseBtn()
            titleLb.text = "pincode_registration_change_pin_code_title".localized
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedReset(_ sender: UIButton) {
        if fromSegue == .SPLASH {
            titleLb.text = "pincode_registration_registration_code_title".localized
        }
        else if fromSegue == .CERTIFICATION {
            titleLb.text = "pincode_registration_change_pin_code_title".localized
        }
        titleLb.textColor = currentTheme.mainText
        detailLb.text = "pincode_registration_sub_title".localized
        detailLb.textColor = currentTheme.detailText
        
        pinCode = ""
        firstPINCode = ""
        isOneMoreConfirmed = false
        setNumberPad(position: 0)
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        if fromSegue == .CERTIFICATION {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
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
    
    private func showCloseBtn() {
        closeImgView.isHidden = false
        closeBtn.isHidden = false
    }
    
    private func handleCompleteRegistration(_ pw: String) {
        
        guard isOneMoreConfirmed else {
            titleLb.text = "pincode_registration_one_more_registration_title".localized
            pinCode = ""
            firstPINCode = pw
            isOneMoreConfirmed = true
            setNumberPad(position: 0)
            return
        }
        
        if pw == firstPINCode {
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
            titleLb.text = "pincode_registration_code_incorrect_title".localized
            titleLb.textColor = currentTheme.errorText
            detailLb.text = "pincode_registration_sub_title_error".localized
            detailLb.textColor = currentTheme.errorText

            self.pinView.setSelectedColor(0)
            self.pinCode = ""
            
            showNumberPad(true)
        }
    }
}

//MARK: - NumberPadDelegate
extension PinCodeRegistrationController: NumberPadDelegate {
    func didTouchedDelete() {
        pinCode = String(pinCode.dropLast())
    }
    
    func didTouchedNumberPad(_ num: String) {
        if pinCode.count == 3 {
            showNumberPad(false)
        }
        
        pinCode += num
    }
}

//MARK: - CharPadDelegate
extension PinCodeRegistrationController: CharPadDelegate {
    func didTouchedCharPad(_ char: String) {
        pinCode += char
        handleCompleteRegistration(pinCode)
    }
    
    func didTouchedDeleteBtn() {
        setNumberPad(position: 3)
        pinCode = String(pinCode.dropLast())
    }
    
    private func setNumberPad(position: Int = 0) {
        pinView.setSelectedColor(position)
        showNumberPad(true)
    }
}

