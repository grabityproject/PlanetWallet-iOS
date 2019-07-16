//
//  MnemonicImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MnemonicImportController: PlanetWalletViewController {

    @IBOutlet var pwTextfield: UITextField!
    @IBOutlet var pwTextFieldContainer: PWView!
    
    @IBOutlet var mnemonicTextView: UITextView!
    @IBOutlet var mnemonicTextViewContainer: PWView!
    
    @IBOutlet var errMsgContainerView: UIView!
    @IBOutlet var invisibleBtn: UIButton!
    @IBOutlet var continueBtn: PWButton!
    
    var planet:Planet = Planet()
    
    private var isValidMnemonic = false {
        didSet {
            updateValidUI()
        }
    }
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateValidUI()
    }
    
    override func viewInit() {
        super.viewInit()
        
        pwTextfield.delegate = self
        mnemonicTextView.delegate = self
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
    @IBAction func didTouchedInvisible(_ sender: UIButton) {
        pwTextfield.isSecureTextEntry = !pwTextfield.isSecureTextEntry
    }
    
    @IBAction func didTouchedContinue(_ sender: UIButton) {
        if let coinType = planet.coinType{
        
            if coinType == CoinType.BTC.coinType{
                
                let importedPlanet = BitCoinManager.shared.importMnemonic(mnemonicPhrase: mnemonicTextView.text, passPhrase: pwTextfield.text ?? "", pinCode: PINCODE)
                
                if let keyId = importedPlanet.keyId{
                    
                    if PlanetStore.shared.get(keyId) != nil{
                        Toast.init(text: "mnemonic_import_exists_title".localized).show()
                        
                    }else{
                        let info = [Keys.UserInfo.planet:importedPlanet]
                        sendAction(segue: Keys.Segue.MNEMONIC_IMPORT_TO_PLANET_NAME, userInfo: info)
                        return
                    }
                }
                else {
                    Toast.init(text: "mnemonic_import_not_match_title".localized).show()
                }
            }else if coinType == CoinType.ETH.coinType{
                
                let importedPlanet = EthereumManager.shared.importMnemonic(mnemonicPhrase: mnemonicTextView.text, passPhrase: pwTextfield.text ?? "", pinCode: PINCODE)
                
                if let keyId = importedPlanet.keyId{
                    
                    if PlanetStore.shared.get(keyId) != nil{
                        Toast.init(text: "mnemonic_import_exists_title".localized).show()
                        
                    }else{
                        let info = [Keys.UserInfo.planet:importedPlanet]
                        sendAction(segue: Keys.Segue.MNEMONIC_IMPORT_TO_PLANET_NAME, userInfo: info)
                        return
                    }
                }
                else {
                    Toast.init(text: "mnemonic_import_not_match_title".localized).show()
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
        if isValidMnemonic {
            continueBtn.setEnabled(true, theme: currentTheme)
            errMsgContainerView.isHidden = true
        }
        else {
            continueBtn.setEnabled(false, theme: currentTheme)
            errMsgContainerView.isHidden = false
        }
    }
}


extension MnemonicImportController: UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        pwTextfield.text = ""
        pwTextfield.resignFirstResponder()
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pwTextFieldContainer.layer.borderColor = currentTheme.border.cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
}

extension MnemonicImportController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        mnemonicTextViewContainer.layer.borderColor = currentTheme.borderPoint.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        mnemonicTextViewContainer.layer.borderColor = currentTheme.border.cgColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        //TODO: - Logic
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        
        if newLength >= 1 {
            isValidMnemonic = true
        }
        else {
            isValidMnemonic = false
        }
        
        return true
    }
}
