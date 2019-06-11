//
//  ViewController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

class SplashController: PlanetWalletViewController{
    
    private var isPinRegistered = true
    let animationView = AnimationView()
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        switch currentTheme {
        case .DARK:         self.animationView.animation = Animation.named("splash")
        case .LIGHT:        self.animationView.animation = Animation.named("splash_wh")
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.topAnchor.constraint(equalTo: view.topAnchor),
                                     animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     animationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     animationView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    override func setData() {
        super.setData()
        
        let planetSHA256 = Crypto.sha256(Data("hello".utf8))
        if let privateKey = Data(hex: "063129a45d7beb11e7e271b4b37bfb907bb11a9a465ac427153d8ca0a69ae913"),
            let signatureStr = Crypto.signer(hash: planetSHA256, privateKey: privateKey)
        {
            let addr = "0d6c5dafa674eef16f0a67c293d57f5f6b507abe"
            let param = ["address" : addr, "signature" : signatureStr, "planet" : "hello"]
            
            Post(self).action( Route.URL("planet","ETH"), requestCode: 0, resultCode: 0, data: param)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { (isSuccess) in
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.checkEntryPoint()
                }
            }
        }
    }
    
    //MARK: - Private 
    private func checkEntryPoint() {
        
        guard let _: String = Utils.shared.getDefaults(for: Keys.Userdefaults.PINCODE) else {
            isPinRegistered = false
            sendAction(segue: Keys.Segue.SPLASH_TO_PINCODE_REGISTRATION, userInfo: nil)
            return
        }
        
        if isPinRegistered {
            sendAction(segue: Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION, userInfo: nil)
        }
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        print(dictionary)
    }
}

