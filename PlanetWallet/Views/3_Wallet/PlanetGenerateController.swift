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
    @IBOutlet var closeImgView: PWImageView!
    @IBOutlet var closeBtn: UIButton!
    
    var planet:Planet?
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if( ThemeManager.currentTheme() == .DARK ){
            darkGradientView.isHidden = false
            lightGradientView.isHidden = true
        }
        else {
            darkGradientView.isHidden = true
            lightGradientView.isHidden = false
        }
    }
    
    override func viewInit() {
        super.viewInit()
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
    }
    
    override func setData() {
        super.setData()
        
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
            }
            
        }
        else if fromSegueID == Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE {
            hideCloseBtn()
            generateETH()
        }
        
        if let planet = self.planet, let address = planet.address {
            nameTextView.text = PlanetStore.shared.createRandomName(address: address) + " "
        }
    }
    
    //MARK: - Private
    private func generateETH(){
        EthereumManager.shared.generateMaster(pinCode: PINCODE)
        self.planet = EthereumManager.shared.addPlanet(index: 0, pinCode: PINCODE)
        
        if let planet = planet, let address = planet.address {
            planetView.data = address
            planetBgView.data = address
        }
    }
    
    private func generateBTC(){
        BitCoinManager.shared.generateMaster(pinCode: PINCODE)
        self.planet = BitCoinManager.shared.addPlanet(index: 0, pinCode: PINCODE)
        if let planet = planet, let address = planet.address {
            planetView.data = address
            planetBgView.data = address
        }
    }
    
    private func addETH(){
        if let planet = planet, let keyId = planet.keyId {
            do{
                _ = try KeyPairStore.shared.deleteKeyPair(keyId: keyId)
                if let pathIndex = planet.pathIndex{
                    self.planet =  EthereumManager.shared.addPlanet(index: pathIndex + 1, pinCode: PINCODE)
                }
            }catch{
                Toast(text: error.localizedDescription).show()
            }
        }else{
            self.planet = EthereumManager.shared.addPlanet(pinCode: PINCODE)
        }
        
        if let planet = planet, let address = planet.address {
            planetView.data = address
            planetBgView.data = address
        }
    }
    
    private func addBTC(){
        if let planet = planet, let keyId = planet.keyId {
            do{
                _ = try KeyPairStore.shared.deleteKeyPair(keyId: keyId)
                if let pathIndex = planet.pathIndex{
                    self.planet =  BitCoinManager.shared.addPlanet(index: pathIndex + 1, pinCode: PINCODE)
                }
            }catch{
                Toast(text: error.localizedDescription).show()
            }
        }else {
            self.planet = BitCoinManager.shared.addPlanet(pinCode: PINCODE)
        }
        
        if let planet = planet, let address = planet.address {
            planetView.data = address
            planetBgView.data = address
        }
    }
    
    private func hideCloseBtn() {
        closeImgView.isHidden = true
        closeBtn.isHidden = true
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedRefresh(_ sender: UIButton) {
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
        
        if nameTextView.text.isEmpty {
            Toast(text: "planet_generate_name_not_blank_title".localized).show()
            return
        }
        
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
            
            Post(self).action(Route.URL("planet", CoinType.of(coinType).name), requestCode: 0, resultCode: 0, data:request.toJSON(), extraHeaders: ["device-key":DEVICE_KEY])
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
        guard success else { return }
        
        guard let planet = planet,
            let keyId = planet.keyId,
            let dict = dictionary,
            let returnVo = ReturnVO(JSON: dict),
            let isSuccess = returnVo.success else { return }
        
        if( isSuccess ){
            PlanetStore.shared.save(planet)
            guard let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String else { return }
            
            if fromSegueID == Keys.Segue.WALLET_ADD_TO_PLANET_GENERATE {
                
                if let isRootMain = userInfo?["isFromMain"] as? Bool {
                    if isRootMain {
                        Utils.shared.setDefaults(for: Keys.Userdefaults.SELECTED_PLANET, value: keyId)
                    }
                }
                
                performSegue(withIdentifier: Keys.Segue.MAIN_NAVI_UNWIND, sender: nil)
            }
            else if fromSegueID == Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE {
                performSegue(withIdentifier: Keys.Segue.PLANET_GENERATE_TO_MAIN, sender: nil)
            }
        }
        else {
            if let errDict = returnVo.result as? [String: Any],
                let errorMsg = errDict["errorMsg"] as? String
            {
                Toast(text: errorMsg).show()
            }
        }
    }
    
}
