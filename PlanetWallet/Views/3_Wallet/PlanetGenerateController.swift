//
//  PlanetGenerateController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetGenerateController: PlanetWalletViewController {

    @IBOutlet var planetBgView: PlanetView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var darkGradientView: GradientView!
    @IBOutlet var lightGradientView: GradientView!
    @IBOutlet var nameTextView: BlinkingTextView!
    
    var planet:Planet?
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
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
    }
    
    override func viewInit() {
        super.viewInit()
        nameTextView.delegateBlinking = self
        
    }
    
    override func setData() {
        super.setData()
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        
        guard let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String else { return }
        
        if fromSegueID == Keys.Segue.WALLET_ADD_TO_PLANET_GENERATE {
        
            if let userInfo = userInfo, let coinType = userInfo[Keys.UserInfo.universe] as? String{
                
                if( coinType == CoinType.BTC.name ){
                    
                    let btcMaster = try! KeyPairStore.shared.getMasterKeyPair(coreCoinType: CoinType.BTC.coinType, pin: PINCODE)
                    if( btcMaster == nil ){
                        generateBTC()
                    }else{
                        addBTC()
                    }
                    
                }else if( coinType == CoinType.ETH.name ){
                    addETH()
                }
                
            }else{
               print("coinType 못가져옴")
            }
            
        }
        else if fromSegueID == Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE {
            generateETH()
        }
    }
    
    func generateETH(){
        EthereumManager.shared.generateMaster(pinCode: PINCODE)
        self.planet = EthereumManager.shared.addPlanet(index: 0, pinCode: PINCODE)
        planetView.data = planet!.address!
        planetBgView.data =  planet!.address!
    }
    
    func generateBTC(){
        BitCoinManager.shared.generateMaster(pinCode: PINCODE)
        self.planet = BitCoinManager.shared.addPlanet(index: 0, pinCode: PINCODE)
        planetView.data = planet!.address!
        planetBgView.data =  planet!.address!
    }
    
    func addETH(){
        if let planet = planet, let keyId = planet.keyId {
            do{
                _ = try KeyPairStore.shared.deleteKeyPair(keyId: keyId)
                if let pathIndex = planet.pathIndex{
                    self.planet =  EthereumManager.shared.addPlanet(index: pathIndex + 1, pinCode: PINCODE)
                }
            }catch{
                print(error)
            }
        }else{
            
            self.planet = EthereumManager.shared.addPlanet(pinCode: PINCODE)
            
        }
        planetView.data = planet!.address!
        planetBgView.data =  planet!.address!
    }
    
    func addBTC(){
        if let planet = planet, let keyId = planet.keyId {
            do{
                _ = try KeyPairStore.shared.deleteKeyPair(keyId: keyId)
                if let pathIndex = planet.pathIndex{
                    self.planet =  BitCoinManager.shared.addPlanet(index: pathIndex + 1, pinCode: PINCODE)
                }
            }catch{
                print(error)
            }
        }else{
            
            self.planet = BitCoinManager.shared.addPlanet(pinCode: PINCODE)
            
        }
        planetView.data = planet!.address!
        planetBgView.data =  planet!.address!
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedRefresh(_ sender: UIButton) {
        //TODO: change planet
        guard let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String else { return }
        
        if fromSegueID == Keys.Segue.WALLET_ADD_TO_PLANET_GENERATE {
            
            if let userInfo = userInfo, let coinType = userInfo[Keys.UserInfo.universe] as? String{
                
                if( coinType == CoinType.BTC.name ){
                    addBTC()
                }else if( coinType == CoinType.ETH.name ){
                    addETH()
                }
            }
        }
        else if fromSegueID == Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE {
            generateETH()
        }
        
    }
    
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        
        if nameTextView.text.contains(" ") {
            self.planet?.name = nameTextView.text.trimmingCharacters(in: .whitespaces)
        }
        else {
            self.planet?.name = nameTextView.text
        }
        
        if let planet = self.planet, let coinType = planet.coinType{
            
            let request = Planet()
            request.signature = Signer.sign(planet.name!, privateKey: planet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE))
            request.planet = planet.name
            request.address = planet.address
            Post(self).action(Route.URL("planet", CoinType.of(coinType).name), requestCode: 0, resultCode: 0, data:request.toJSON())
            
        }
        
        
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTap() {
        self.view.endEditing(true)
    }
    
    //MARK: - Notification
    override func keyboardWillShow(notification: NSNotification) {
        if let tapGesture = tapGestureRecognizer {
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        if let tapGesture = tapGestureRecognizer {
            view.removeGestureRecognizer(tapGesture)
        }
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if let dict = dictionary{
            let response = ReturnVO(JSON: dict)
            if( response!.success! ){
                PlanetStore.shared.save(planet!)
                
                guard let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String else { return }
                
                if fromSegueID == Keys.Segue.WALLET_ADD_TO_PLANET_GENERATE {
                    performSegue(withIdentifier: Keys.Segue.MAIN_NAVI_UNWIND, sender: nil)
                }
                else if fromSegueID == Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE {
                    performSegue(withIdentifier: Keys.Segue.PLANET_GENERATE_TO_MAIN, sender: nil)
                }
            }
            else {
                if let errDic = response?.result as? [String: Any],
                    let errorMsg = errDic["errorMsg"] as? String
                {
                    Toast(text: errorMsg).show()
                }
            }
        }
        
    }
}

extension PlanetGenerateController: BlinkingTextViewDelegate {
    
    func didEndEditing(_ textView: BlinkingTextView) {
        
    }
    
    func didBeginEditing(_ textView: BlinkingTextView) {
        
    }
}
