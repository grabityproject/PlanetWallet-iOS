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

        
        
//        Get(self).action( "http://13.209.47.168/test/apiTest.php", requestCode:0, resultCode:0, data:nil )
//        Get(self).action( "http://13.209.47.168/test/apiTestddd.php", requestCode:1, resultCode:0, data:["name":"kyu"] )
//        Get(self).action( "http://13.209.47.168/api/index.php/Api/error/505", requestCode:3, resultCode:1, data:nil )
        
//        Post(self).action("http://13.209.47.168/api/index.php/Api", requestCode: 1, resultCode: 0, data: ["params":"string", "numeric":100]);
//        Patch(self).action("http://13.209.47.168/api/index.php/Api", requestCode: 2, resultCode: 0, data: ["params":"string", "numeric":100]);
//        Put(self).action("http://13.209.47.168/api/index.php/Api", requestCode: 3, resultCode: 0, data: ["params":"string", "numeric":100]);
//        Delete(self).action("http://13.209.47.168/api/index.php/Api", requestCode: 4, resultCode: 0, data: ["params":"string", "numeric":100]);
//
        if let img = UIImage(named:"tokenIconBTC.png") {
            let imgData = img.jpegData(compressionQuality: 1.0)
//            Post(self).actionMultipart("http://13.209.47.168/api/index.php/Api/file", requestCode: 1, resultCode: 0, data: imgData)
            
            
            
            
            Post(self).action(
                Route.URL("index.php", "Api", "file"),
                              requestCode: 22,
                              resultCode: 0,
                              data:
                ["imageDat":imgData,
                "params":"string",
                 "numeric":100]);

            
            
        }
        
        
        
        Post(self).action(
            Route.URL("index.php", "Api", "file"),
                          requestCode: 11,
                          resultCode: 0,
                          data:
            ["desc":"my name is moon"]);

        
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { (isSuccess) in
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.checkEntryPoint()
                }
            }
        }
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        print( "[\(requestCode)]" + (success ? "SUCCESS" : "FAIL") + ", statusCode : \(statusCode)" + ", result : \(result)" )
        
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

