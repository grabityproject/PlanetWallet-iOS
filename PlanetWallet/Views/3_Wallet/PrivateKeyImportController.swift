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
    
    @IBOutlet var errMsgContainerView: UIView!
    @IBOutlet var continueBtn: PWButton!
    
    private var isValidPrivateKey = false {
        didSet {
            updateValidUI()
        }
    }
    
    var planet:Planet = Planet()
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateValidUI()
    }
    
    override func viewInit() {
        super.viewInit()
        textField.delegate = self
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
    }
    
    @IBAction func didTouchedContinue(_ sender: UIButton) {
        
        if let coinType = planet.coinType, let privateKey = textField.text {
            
            if coinType == CoinType.BTC.coinType{
                planet = BitCoinManager.shared.importPrivateKey(privKey: privateKey, pinCode: PINCODE)
                
                if let keyId = planet.keyId{
                    if PlanetStore.shared.get(keyId) != nil{
                        //TODO: - Alert Message
                        Toast.init(text: "-------겹침!!!!------").show()
                    }else{
                        let info = [Keys.UserInfo.planet:planet]
                        sendAction(segue: Keys.Segue.PRIVATEKEY_IMPORT_TO_PLANET_NAME, userInfo: info)
                        return
                    }
                }

            }else if coinType == CoinType.ETH.coinType{
                planet = EthereumManager.shared.importPrivateKey(privKey: privateKey, pinCode: PINCODE)
                
                if let keyId = planet.keyId{
                    if PlanetStore.shared.get(keyId) != nil{
                        //TODO: - Alert Message
                        Toast.init(text: "-------겹침!!!!------").show()
                    }else{
                        let info = [Keys.UserInfo.planet:planet]
                        sendAction(segue: Keys.Segue.PRIVATEKEY_IMPORT_TO_PLANET_NAME, userInfo: info)
                        return
                    }
                }
            }
            
        }
    }
    
    
    //MARK: - Private
    private func isValid(mnemonic: String) -> Bool {
        //TODO: - Logic
        return false
    }
    
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
        let length = textFieldText.utf16.count + string.utf16.count - range.length
        
        if length >= 1 {
            isValidPrivateKey = true
        }
        else {
            isValidPrivateKey = false
        }
        
        return true
    }
}
