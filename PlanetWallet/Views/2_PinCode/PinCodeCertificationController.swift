//
//  PinCodeCertificationController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit


class PinCodeCertificationController: PlanetWalletViewController {
    
    private var passwordStr = "" {
        didSet {
            pinView.setSelectedColor(passwordStr.count)
        }
    }
    
    @IBOutlet var pinView: PinView!
    @IBOutlet var charPad: CharPad!
    @IBOutlet var numPad: NumberPad!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewInit() {
        charPad.delegate = self
        numPad.delegate = self
    }
    
    override func setData() {
        
    }
    
    
    
    private func handleSuccessSignIn() {
        //TODO: - navigation
        //이전 vc에 따라 다음 vc가 정해짐
        sendAction(segue: Keys.Segue.TO_WALLETADD, userInfo: nil)
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
    func didTouchedNumberPad(_ num: String) {
        if num.count == 4 {
            showNumberPad(false)
        }
        
        passwordStr = num
    }
}

extension PinCodeCertificationController: CharPadDelegate {
    func didTouchedCharPad(_ char: String) {
        guard let savedPassword = UserDefaults.standard.value(forKey: "pincode") as? String else { return }
        
        self.passwordStr = passwordStr + char
        if passwordStr == savedPassword {    // Success to sign in
            handleSuccessSignIn()
        }
        else {
            self.passwordStr = ""
            self.numPad.resetPassword()
            self.charPad.resetPassword()
            
            showNumberPad(true)
        }
    }
    
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool) {
        if isBack {
            pinView.setSelectedColor(3)
            numPad.deleteLastPW()
            showNumberPad(true)
        }
    }
    
    
}


