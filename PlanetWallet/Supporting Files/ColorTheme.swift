//
//  ColorTheme.swift
//  PlanetWallet
//
//  Created by grabity on 08/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

/*
 dark : (17,17,23)
 darkTwo : (30,30,40)
 
 slateGrey : (92,89,100)
 lightGrey : (170, 170, 170)
 dimGrey : (207,207,207)
 sliver : (237,237,237)
 lightBlueGrey : (188,189,213)
 
 pinkRed : (255,0,80)
 
extension UIColor {
    struct Dark {
        static let OIL = UIColor(red: 17, green: 17, blue: 23)
        static let MIDNIGHT = UIColor(red: 30, green: 30, blue: 40)
    }
    
    struct Gray {
        static let SLATE = UIColor(red: 92, green: 89, blue: 100)
        static let LIGHT_SLATE = UIColor(red: 170, green: 170, blue: 170)
        static let DIM = UIColor(red: 207, green: 207, blue: 207)
        static let SILVER = UIColor(red: 237, green: 237, blue: 237)
        static let LIGHT_BLUE = UIColor(red: 189, green: 189, blue: 213)
        static let WHITE = UIColor(red: 252, green: 252, blue: 252)
    }
    
    struct Red {
        static let PINK = UIColor(red: 255, green: 0, blue: 80)
    }
}
*/
 
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
        case .DARK:     return UIColor(named: "detailTextDark")!//return UIColor.Gray.SLATE
        case .LIGHT:    return UIColor(named: "detailTextLight")!//return UIColor.Gray.LIGHT_SLATE
        }
    }
    
    var errorText: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "errorText")!//return UIColor.Red.PINK
        case .LIGHT:    return UIColor(named: "errorText")!//return UIColor.Red.PINK
        }
    }
    
    var textFieldBackground: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "textFieldBgDark")!//return UIColor.Dark.OIL
        case .LIGHT:    return UIColor(named: "textFieldBgLight")!//return UIColor.white
        }
    }
    
    var border: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "borderDark")!//return UIColor.Dark.MIDNIGHT
        case .LIGHT:    return UIColor(named: "borderLight")!//return UIColor.Gray.SILVER
        }
    }
    
    var borderPoint: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "borderPointDark")!//return UIColor.Gray.LIGHT_BLUE
        case .LIGHT:    return UIColor(named: "borderPointLight")!//return UIColor.black
        }
    }
    
    var disableViewBg: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "disableBgDark")!//return UIColor.Dark.MIDNIGHT
        case .LIGHT:    return UIColor(named: "disableBgLight")!//return UIColor.Gray.SILVER
        }
    }
    
    var disableText: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "disableTextDark")!//return UIColor.Gray.SLATE
        case .LIGHT:    return UIColor(named: "disableTextLight")!//return UIColor.Gray.DIM
        }
    }
    
    var pinCode: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "pinCodeDark")!//return UIColor.Gray.SLATE
        case .LIGHT:    return UIColor(named: "pinCodeLight")!//return UIColor.Gray.LIGHT_BLUE
        }
    }
    
    var searchBar: UIColor {
        switch self {
        case .DARK:     return UIColor(named: "searchBarDark")!//return UIColor.Dark.OIL
        case .LIGHT:    return UIColor(named: "searchBarLight")!//return UIColor.Gray.WHITE
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
    
    var magneticImg: UIImage? {
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
    
    static func setTheme(_ theme: Theme) {
        Utils.shared.setDefaults(for: Keys.Userdefaults.THEME, value: theme.rawValue)
    }
    
    static func applyTheme(theme: Theme) {
        setTheme(theme)
        
        // You get your current (selected) theme and apply the main color to the tintColor property of your application’s window.
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.backgroundColor
        
        /*
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")
        
        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage
        
        let tabIndicator = UIImage(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
        let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
        UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator
        
        let controlBackground = UIImage(named: "controlBackground")?.withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        let controlSelectedBackground = UIImage(named: "controlSelectedBackground")?
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        
        UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
        UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)
        
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .disabled)
        UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
        UIStepper.appearance().setDecrementImage(UIImage(named: "fewerPaws"), for: .normal)
        UIStepper.appearance().setIncrementImage(UIImage(named: "morePaws"), for: .normal)
        
        UISlider.appearance().setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "maximumTrack")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 6.0)), for: .normal)
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "minimumTrack")?
            .withRenderingMode(.alwaysTemplate)
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 6.0, bottom: 0, right: 0)), for: .normal)
        
        UISwitch.appearance().onTintColor = theme.mainColor.withAlphaComponent(0.3)
        UISwitch.appearance().thumbTintColor = theme.mainColor
         */
    }
}
