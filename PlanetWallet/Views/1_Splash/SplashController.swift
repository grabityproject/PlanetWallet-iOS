//
//  ViewController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

class SplashController: PlanetWalletViewController {
    
    private var isPinRegistered = true
    let animationView = AnimationView()
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        self.animationView.animation = Animation.named("splash")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.topAnchor.constraint(equalTo: view.topAnchor),
                                     animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     animationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     animationView.rightAnchor.constraint(equalTo: view.rightAnchor)])
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
}

