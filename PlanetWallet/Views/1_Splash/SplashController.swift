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
        
        //API Test
        /*
        let planetSHA256 = Crypto.sha256(Data("hello".utf8))
        if let privateKey = Data(hex: "7ea08053ee80061f17e6297312835d5b7a3101cf02c53590c85ea33fb85d2246"),
            let signatureStr = Crypto.signer(hash: planetSHA256, privateKey: privateKey)
        {
            let addr = "5232a466b9ddd048b5c118070c72902889ee8c51"
            let param = ["address" : addr, "signature" : signatureStr, "planet" : "hello"]
            
            Post(self).action( Route.URL("planet","ETH"), requestCode: 0, resultCode: 0, data: param)
        }
         */
        
        Get(self).action(Route.URL("erc20"), requestCode: 0, resultCode: 0, data: nil)
        
        
        //DB Test
        /*
        try! PlanetWalletDBManger.shared.insertTest()
        try! PlanetWalletDBManger.shared.insertTest()
        try! PlanetWalletDBManger.shared.loadTest()
         */
        
        if PlanetWalletDBManger.shared.database.columnExists("addedField", inTableWithName: "Test") {
            print("success to update tables")
        }
        else {
            print("failed to update tables")
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
        if let resultJson = result as? [Dictionary<String, Any>]
        {
            let tokens:[ERCTokenSample] = Mapper<ERCTokenSample>().mapArray(JSONArray: resultJson)
        }
    }
}


class ERCTokenSample: Mappable {
    var contractAddress: String?
    var decimal: Int?
    var imgPath: String?
    var name: String?
    var symbol: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.contractAddress     <- map["contract_address"]
        self.decimal             <- map["decimal"]
        self.imgPath             <- map["img_path"]
        self.name                <- map["name"]
        self.symbol              <- map["symbol"]
    }
}

