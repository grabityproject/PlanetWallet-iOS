//
//  AppConstant.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

let DEFAULT_PLIST_NAME = "Preference"

//MARK: - Screen
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)

var THEME: Theme {
    get {
        return UserDefaults.standard.bool(forKey: "environment.theme") ? Theme.LIGHT : Theme.DARK
    }
}

func setTheme( theme: Theme ){
    UserDefaults.standard.set(theme == Theme.LIGHT, forKey: "environment.theme")
}

struct Keys {
    struct Userdefaults {
        static let PINCODE = "pincode"
    }
    
    struct Segue {
        static let TO_PINCODE_REGISTRATION = "splash_to_pincoderegistration"
        static let PINCODE_REGISTRATION_TO_CERTIFICATION = "pincoderegistration_to_pincodecertification"
        static let TO_WALLETADD = "pincodecertification_to_walletadd"
        static let PINCODE_REGISTRATION_TO_MAIN = "pincodecertification_to_main"
    }
}
