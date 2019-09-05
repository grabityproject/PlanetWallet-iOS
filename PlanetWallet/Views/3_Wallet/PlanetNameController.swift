//
//  PlanetNameController.swift
//  PlanetWallet
//
//  Created by grabity on 04/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetNameController: PlanetWalletViewController {
    static let MAX_COUNT_OF_NAME: Int = 20
    
    @IBOutlet var planetBgView: PlanetView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var darkGradientView: GradientView!
    @IBOutlet var lightGradientView: GradientView!
    @IBOutlet var nameTextView: BlinkingTextView!
    
    var planet: Planet?
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if( ThemeManager.currentTheme() == .DARK ){
            darkGradientView.isHidden = false
            lightGradientView.isHidden = true
        }else{
            darkGradientView.isHidden = true
            lightGradientView.isHidden = false
        }
        
        if let planet = self.planet, let address = planet.address {
            planetBgView.data = address
            planetView.data = address
        }
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo, let planet = userInfo[Keys.UserInfo.planet] as? Planet {
            self.planet = planet
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        
        if nameTextView.text.isEmpty {
            Toast(text: "Input planet name").show()
            return
        }
        
        self.planet?.name = nameTextView.text
        
        if let planet = self.planet, let coinType = planet.coinType{
            
            let request = Planet()
            request.signature = Signer.sign(planet.name!, privateKey: planet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE))
            request.planet = planet.name
            request.address = planet.address
            Post(self).action(Route.URL("planet", CoinType.of(coinType).name), requestCode: 0, resultCode: 0, data:request.toJSON(), extraHeaders: ["device-key":DEVICE_KEY])
        }
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard let dict = dictionary,
            let planet = self.planet,
            let returnVo = ReturnVO(JSON: dict),
            let isSuccess = returnVo.success else { return }
        
        if isSuccess {
            PlanetStore.shared.save(planet)
            sendAction(segue: Keys.Segue.MAIN_NAVI_UNWIND, userInfo: nil)
        }
        else {
            if let errDic = returnVo.result as? [String: Any],
                let errorMsg = errDic["errorMsg"] as? String
            {
                Toast(text: errorMsg).show()
            }
        }
    }
}
