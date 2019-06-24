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
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.topAnchor.constraint(equalTo: view.topAnchor),
                                     animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     animationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     animationView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    override func setData() {
        super.setData()
        

        /*
        let planet = Planet()
        planet.address = "0x123123123123123123123123"
        planet.name = "Name"
        planet.coinType = 60
        planet.decimals = "18"
        planet.hide = "N"
        planet.keyId = "alsdkmalsdkmalsdkmalskdmalksdmalskdmlaskdmalksmd"

        print(planet.coinType)
        
        print(planet.toJSON())
        print(planet.toJSONString())
        
        print(PWDBManager.shared.insert(planet))
        print(try! PWDBManager.shared.select(Planet.self))
         */

        /*
        let planet = Planet()
        planet.address = "0x36072b48604d6d83b5bb304d36887b00213433d5"
        planet.planet = "I_am_moon"
        planet.signature = Signer.sign(planet.planet!, privateKey: "BA40B4A0375F46A04C75FD737971CECF873A4AE09E48B0FF82C7E3F086E95D7C")

        Post(self).action(Route.URL("planet", CoinType.ETH.name ), requestCode: 0, resultCode: 0, data: planet.toJSON())
         */
        
        
//
//        planet.items = Array<MainItem>()
//        planet.items?.append(ETH())
//        planet.items?.append(ERC20())
//
//        print(Signer.sign("Planet2", privateKey: "BA40B4A0375F46A04C75FD737971CECF873A4AE09E48B0FF82C7E3F086E95D7C"))
        
        
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

        if let dict = dictionary{
            if let returnVo = ReturnVO(JSON: dict){
                print(returnVo.result)
                
                
                
                
                //
                //            print( Bool( dict["success"] as! NSNumber ) )
                //            print(dict["success"])
                //            print(dict["result"])
                
                //            if( Bool( ){
                //               let result = Planet(JSON: dict["result"])
                //            }
                
            }
        }
        
        
//        if let resultJson = result as? [Dictionary<String, Any>]
//        {
//            print(result)
////            let tokens:[ERCToken] = Mapper<ERCToken>().mapArray(JSONArray: resultJson)
//        }
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

