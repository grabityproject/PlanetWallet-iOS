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

//var THEME: Theme {
//    get {
//        return UserDefaults.standard.bool(forKey: "environment.theme") ? Theme.LIGHT : Theme.DARK
//    }
//}
//
//func setTheme( theme: Theme ){
//    UserDefaults.standard.set(theme == Theme.LIGHT, forKey: "environment.theme")
//}

struct Keys {
    struct Userdefaults {
        static let THEME = "theme"
        static let PINCODE = "pincode"
    }
    
    struct Segue {
        static let TO_PINCODE_REGISTRATION = "splash_to_pincoderegistration"
        static let PINCODE_REGISTRATION_TO_CERTIFICATION = "pincoderegistration_to_pincodecertification"
        static let TO_WALLETADD = "pincodecertification_to_walletadd"
        static let PINCODE_REGISTRATION_TO_MAIN = "pincodecertification_to_main"
        
        //WALLET ADD
        static let WALLET_IMPORT_TO_MNEMONIC_IMPORT = "walletimport_to_mnemonicImport"
        static let WALLET_IMPORT_TO_PRIVATEKEY_IMPORT = "walletimport_to_privatekeyimport"
        static let WALLET_IMPORT_TO_JSON_IMPORT = "walletimport_to_jsonimport"
        
        //MAIN
        static let MAIN_TO_SETTING = "main_to_setting"
        static let MAIN_TO_TOKEN_ADD = "main_to_tokenadd"
        static let MAIN_TO_TRANSFER = "main_to_transfer"
        
        //Setting
        static let SETTING_TO_PLANET_MANAGEMENT = "setting_to_planetmanagemnet"
        static let SETTING_TO_ACCOUNT = "setting_to_account"
        static let SETTING_TO_DETAIL_SETTING = "setting_to_detailsetting"
        static let SETTING_TO_ANNOUNCEMENTS = "setting_to_announcements"
        static let SETTING_TO_FAQ = "setting_to_faq"
        
        //Setting_PlanetManagement
        static let PLANET_MANAGEMENT_TO_DETAIL_PLANET = "planetmanagement_to_detailplanet"
        
    }
}
