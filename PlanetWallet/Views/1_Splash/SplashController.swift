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
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        switch currentTheme {
        case .DARK:         self.animationView.animation = Animation.named("splash_03_bk")
        case .LIGHT:        self.animationView.animation = Animation.named("splash_03_wh")
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
        
        if let resultJson = result as? [Dictionary<String, Any>]
        {
            print(result)
//            let tokens:[ERCToken] = Mapper<ERCToken>().mapArray(JSONArray: resultJson)
        }
    }
}


class TestObject: Mappable {
    var id: String?
    var name: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id             <- map["id"]
        self.name           <- map["name"]
    }
}

