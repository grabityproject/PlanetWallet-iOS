//
//  ViewController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class SplashController: UIViewController {

    let segueToPincodeRegistration = "splash_to_pincoderegistration"
    
    var isPinRegistered = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isPinRegistered {
            let pinCodeCertificationVC = UIStoryboard(name: "2_PinCode", bundle: nil).instantiateViewController(withIdentifier: "PinCodeCertificationController")
            self.present(pinCodeCertificationVC, animated: false, completion: nil)
        }
        else {
            performSegue(withIdentifier: segueToPincodeRegistration, sender: nil)
        }
    }

}

