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
            else if fromSegueID == From.CERTIFICATION.segueID() {
                fromSegue = .CERTIFICATION
            }
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
    
    private func handleCompleteRegistration(_ pw: String) {
        Utils.shared.setDefaults(for: Keys.Userdefaults.PINCODE, value: pw)
        
        switch fromSegue {
        case .SPLASH:
            sendAction(segue: Keys.Segue.PINCODE_REGISTRATION_TO_CERTIFICATION, userInfo: nil)
        case .CERTIFICATION:
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension PinCodeRegistrationController: NumberPadDelegate {
    func didTouchedNumberPad(_ num: String) {
        if num.count == 4 {
            showNumberPad(false)
        }
        passwordStr = num
    }
}

extension PinCodeRegistrationController: CharPadDelegate {
    func didTouchedCharPad(_ char: String) {
        //Register pincode
        passwordStr += char
        
        handleCompleteRegistration(passwordStr)
    }
    
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool) {
        if isBack {
            pinView.setSelectedColor(3)
            numPad.deleteLastPW()
            showNumberPad(true)
        }
    }
    
    
}

