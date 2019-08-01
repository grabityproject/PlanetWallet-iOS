//
//  KeyPadViewModel.swift
//  PlanetWallet
//
//  Created by grabity on 01/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class PINCode {
    
    let maxNumOfPIN = 5
    
    //PIN Code는 문자 패드와 숫자 패드로 구성되어 있다.
    var isCharPad: Bool {
        return pinStr.count == 4
    }
    //입력받은 PIN Code
    var pinStr = ""
}

class KeyPadViewModel: NSObject {
    private let inCorrectTitle = "pincode_certification_code_incorrect_title".localized
    private let inCorrectDetailTitle = "pincode_certification_sub_title_error".localized
    private let inCorrectTextColor = ThemeManager.currentTheme().errorText
    
    private let pinCode: PINCode!
    
    public var title = ""
    public var detailTitle = ""
    public var textColor = ThemeManager.currentTheme().mainText
    
    init(pinCode: PINCode = PINCode() ) {
        self.pinCode = pinCode
    }
    
    
}

