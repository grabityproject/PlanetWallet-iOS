//
//  AppDelegate.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import pcwf

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var pinCode = [String]()
    
    /**
     * PIN 기반 암호화 담당.
     */
    let pinBasedKeyCrypter: PinBasedKeyCrypter = PinBasedKeyCrypterService()
    /**
     * 키스토어에서 사용할 키의 식별자.
     */
    let keystoreAlias = "TEE_ALIAS"
    /**
     * 하드웨어 보안 모듈 기반 암호화.
     */
    let hsmKeyCrypter: HsmKeyCrypter = KeyStoreCrypter()
    /**
     * 민감한 정보 저장을 위해 사용하는 암복호화 클래스.
     */
    lazy var defaultCryper: DefaultStorageCryper = DefaultStorageCryper(keyAlias: keystoreAlias, pinBasedKeyCryper: pinBasedKeyCrypter, hsmKeyCryper: hsmKeyCrypter)
    
    var window: UIWindow?
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        createDatabase()
        initSecureModules()
        
        setNavigationBar()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if (topController is PinCodeCertificationController) == false &&
                (topController is PinCodeRegistrationController) == false &&
                (topController is SplashController) == false
            {
                let signInController = UIStoryboard(name: "2_PinCode", bundle: nil).instantiateViewController(withIdentifier: "PinCodeCertificationController") as! PinCodeCertificationController
                signInController.userInfo = [Keys.UserInfo.fromSegue: Keys.Segue.BACKGROUND_TO_FOREGROUND_PINCODE_CERTIFICATION]
                
                topController.present(signInController, animated: true, completion: nil)
            }
        }
    }

    private func createDatabase() {
        _ = PWDBManager.shared
    }
    
    private func initSecureModules(){
        KeyPairStore.shared.defaultCrypter = defaultCryper
        KeyStore.shared.defaultCrypter = defaultCryper
        
        _ = PlanetStore.shared
        _ = ERC20Store.shared
    }

    private func setNavigationBar() {
        // set navigation bar transparanct
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        
        // set back button title hidden
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "Helvetica-Bold",
                                                               size: 0.1)!, NSAttributedString.Key.foregroundColor: UIColor.clear]
        
        BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
    }
}

