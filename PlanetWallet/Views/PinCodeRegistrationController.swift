//
//  PinCodeRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PinCodeRegistrationController: PlanetWalletViewController {
    
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
    
    
    
    private func moveToHomeVC() {
        //        if isAppLaunchedEnter {
        //            let vc = UIStoryboard(name: "3_Home", bundle: nil).instantiateViewController(withIdentifier: "mainNavigation")
        //            self.present(vc, animated: true, completion: nil)
        //        }
        //        else {
        //            dismiss(animated: true, completion: nil)
        //        }
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
        UserDefaults.standard.set(passwordStr, forKey: "pincode")
        
        //move to certification pincode
        sendAction(segue: Keys.Segue.PINCODE_REGISTRATION_TO_CERTIFICATION, userInfo: nil)
    }
    
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool) {
        if isBack {
            pinView.setSelectedColor(3)
            numPad.deleteLastPW()
            showNumberPad(true)
        }
    }
    
    
}

