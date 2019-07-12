//
//  ViewController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie
import ObjectMapper


class SplashController: PlanetWalletViewController{
    
    private var isPinRegistered = true
    let animationView = AnimationView()
    
    var planet : Planet?
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()

        switch currentTheme {
        case .DARK:         self.animationView.animation = Animation.named("splash_03_bk")
        case .LIGHT:        self.animationView.animation = Animation.named("splash_03_wh")
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor),
                                     animationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 38),
                                     animationView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -38)])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { (isSuccess) in
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.moveEntryPoint()
                }
            }
        }
    }
    
    //MARK: - Private 
    private func moveEntryPoint() {
        guard let _: String = Utils.shared.getDefaults(for: Keys.Userdefaults.PINCODE) else {
            isPinRegistered = false
            sendAction(segue: Keys.Segue.SPLASH_TO_PINCODE_REGISTRATION,
                       userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.SPLASH_TO_PINCODE_REGISTRATION])
            return
        }
        
        if isPinRegistered {
            sendAction(segue: Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION,
                       userInfo: [Keys.UserInfo.fromSegue: Keys.Segue.SPLASH_TO_PINCODE_CERTIFICATION])
        }
    }
    
}
