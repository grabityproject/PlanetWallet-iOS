//
//  ColorTheme.swift
//  PlanetWallet
//
//  Created by grabity on 08/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

enum Theme: Int {
    case DARK = 0, LIGHT
    
    var backgroundColor: UIColor {
        switch self {
        case .DARK:     return UIColor.black
        case .LIGHT:    return UIColor.white
        }
    }
    
    var mainText: UIColor {
        switch self {
        case .DARK:     return UIColor.white
        case .LIGHT:    return UIColor.black
        }
    }
    
    var detailText: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "detailTextDark")!
        case .LIGHT:    return UIColor(named: "detailTextLight")!
        }
    }
    
    var errorText: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "errorText")!
        case .LIGHT:    return UIColor(named: "errorText")!
        }
    }
    
    var textFieldBackground: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "textFieldBgDark")!
        case .LIGHT:    return UIColor(named: "textFieldBgLight")!
        }
    }
    
    var border: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "borderDark")!
        case .LIGHT:    return UIColor(named: "borderLight")!
        }
    }
    
    var borderPoint: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "borderPointDark")!
        case .LIGHT:    return UIColor(named: "borderPointLight")!
        }
    }
    
    var disableViewBg: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "disableBgDark")!
        case .LIGHT:    return UIColor(named: "disableBgLight")!
        }
    }
    
    var disableText: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "disableTextDark")!
        case .LIGHT:    return UIColor(named: "disableTextLight")!
        }
    }
    
    var pinCode: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "pinCodeDark")!
        case .LIGHT:    return UIColor(named: "pinCodeLight")!
        }
    }
    
    var searchBar: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "searchBarDark")!
        case .LIGHT:    return UIColor(named: "searchBarLight")!
        }
    }
    
    var naviBackImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageToolbarBackGray")
        case .LIGHT:    return UIImage(named: "imageToolbarBackBlue")
        }
    }
    
    var naviUniverseImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageToolbarPlanetmenuGray")
        case .LIGHT:    return UIImage(named: "imageToolbarPlanetmenuBlue")
        }
    }
    
    var naviCloseImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageToolbarCloseGray")
        case .LIGHT:    return UIImage(named: "imageToolbarCloseBlue")
        }
    }
    
    var naviMutiUniverseImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageToolbarMutiuniverseGray")
        case .LIGHT:    return UIImage(named: "icHeaderMutiuniverseBlue")
        }
    }
    
    var clearTxtImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageInputClearBlue")
        case .LIGHT:    return UIImage(named: "imageInputClearBlack")
        }
    }
    
    var magnifyingPointImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageSearchWhite")
        case .LIGHT:    return UIImage(named: "imageSearchBlack")
        }
    }
    
    var magnifyingImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageSearchDarkgray")
        case .LIGHT:    return UIImage(named: "imageSearchGray")
        }
    }
    
    var invisibleImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageInputInvisibleDarkgray")
        case .LIGHT:    return UIImage(named: "imageInputInvisibleGray")
        }
    }
    
    var transferETHImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageTransferEthGray")
        case .LIGHT:    return UIImage(named: "imageTransferEthBlue")
        }
    }
    
    var transferBTCImg: UIImage? {
        switch self {
        case .DARK:     return UIImage(named: "imageTransferBtcGray")
        case .LIGHT:    return UIImage(named: "imageTransferBtcBlue")
        }
    }
}


class ThemeManager {
    
    // ThemeManager
    static func currentTheme() -> Theme {
        
        if let storedTheme: Int? = Utils.shared.getDefaults(for: Keys.Userdefaults.THEME),
            let currentTheme = storedTheme {
            return Theme(rawValue: currentTheme)!
        } else {
            return .DARK
        }
    }
    
    static func settingTheme() -> Theme {
        
        if let storedTheme: Int? = Utils.shared.getDefaults(for: Keys.Userdefaults.THEME),
            let currentTheme = storedTheme {
            
            switch Theme(rawValue: currentTheme)! {
            case .DARK:     return .LIGHT
            case .LIGHT:    return .DARK
            }
        } else {
            return .LIGHT
        }
    }
    
    static func setTheme(_ theme: Theme) {
        Utils.shared.setDefaults(for: Keys.Userdefaults.THEME, value: theme.rawValue)
    }
    
    static func applyTheme(theme: Theme) {
        setTheme(theme)
        
        // You get your current (selected) theme and apply the main color to the tintColor property of your application’s window.
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.backgroundColor
    }
}
