//
//  PrivateKeyImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PrivateKeyImportController: PlanetWalletViewController {

    @IBOutlet var pwTextFieldContainer: PWView!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var invisibleImgView: PWImageView!
    
    @IBOutlet var errMsgContainerView: UIView!
    @IBOutlet var continueBtn: PWButton!
    
    private var isValidPrivateKey = false {
        didSet {
            updateValidUI()
        }
    }
    
    var planet:Planet = Planet()
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        textField.delegate = self
        continueBtn.setEnabled(true, theme: currentTheme)
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo, let universeType = userInfo[Keys.UserInfo.universe] as? String {
            if universeType == CoinType.BTC.name {
                planet.coinType = CoinType.BTC.coinType
            }
            else if universeType == CoinType.ETH.name {
                planet.coinType = CoinType.ETH.coinType
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedInvisible(_ sender: PWButton) {
        
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        
        if textField.isSecureTextEntry {
            invisibleImgView.image = ThemeManager.currentTheme().invisibleImg
        }
        else {
            invisibleImgView.image = UIImage(named: "imageInputVisible")
        }
    }
    
    
    var importedPlanet:Planet?
    
    @IBAction func didTouchedContinue(_ sender: UIButton) {
        
        if let coinType = planet.coinType, let privateKey = textField.text {
            

            
            if coinType == CoinType.BTC.coinType{
                importedPlanet = BitCoinManager.shared.importPrivateKey(privKey: privateKey, pinCode: PINCODE)
            }else if coinType == CoinType.ETH.coinType{
                importedPlanet = EthereumManager.shared.importPrivateKey(privKey: privateKey, pinCode: PINCODE)
            }
            
            
            if let planet = importedPlanet, let _ = planet.keyId {
              
                self.planet = planet
                
                if let symbol = planet.symbol, let address = planet.address{
                    Get(self).action(Route.URL("planet","search",symbol), requestCode: 0, resultCode: 0, data: ["q":address])
                }
              
            }
            else {
                Toast.init(text: "privatekey_import_not_match_title".localized).show()
            }
        }
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        guard success else { return }
        
        guard let planet = importedPlanet,
            let keyId = planet.keyId,
            let dict = dictionary,
            let returnVo = ReturnVO(JSON: dict),
            let results = returnVo.result as? Array<Dictionary<String, Any>> else { return }
        
        if PlanetStore.shared.get(keyId) != nil{
            Toast.init(text: "privatekey_import_exists_title".localized).show()
        }
        else {
            if let isFromMain = userInfo?["isFromMain"] as? Bool {
                //기존에 Planet이 있을 경우
                if results.count > 0 {
                    if let item = results.first, let name = item["name"] as? String {
                        planet.name = name
                        
                        if isFromMain {
                            Utils.shared.setDefaults(for: Keys.Userdefaults.SELECTED_PLANET, value: keyId)
                        }
                        
                        PlanetStore.shared.save(planet)
                        sendAction(segue: Keys.Segue.MAIN_UNWIND, userInfo: nil)
                        return
                    }
                }
                
                sendAction(segue: Keys.Segue.PRIVATEKEY_IMPORT_TO_PLANET_NAME, userInfo: [Keys.UserInfo.planet: planet,
                                                                                        "isFromMain" : isFromMain])
                
            }
        }
        
    }
    
    //MARK: - Private
    private func updateValidUI() {
        if isValidPrivateKey {
            continueBtn.setEnabled(true, theme: currentTheme)
            errMsgContainerView.isHidden = true
        }
        else {
            continueBtn.setEnabled(false, theme: currentTheme)
            errMsgContainerView.isHidden = false
        }
    }
}

//MARK: - UITextFieldDelegate
extension PrivateKeyImportController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        isValidPrivateKey = false
        textField.resignFirstResponder()
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.border.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else { return false }
        
        if textFieldText.utf16.count + string.utf16.count - range.length >= 1 {
            isValidPrivateKey = true
        }
        else {
            isValidPrivateKey = false
        }
        
        return true
    }
}
