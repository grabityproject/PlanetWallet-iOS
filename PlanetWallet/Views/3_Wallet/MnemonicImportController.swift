//
//  MnemonicImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import pcwf.ObjcWrapper
import pcwf.Swift
import pcwf.pallet_core_wrapper


class MnemonicImportController: PlanetWalletViewController {

    @IBOutlet var pwTextfield: UITextField!
    @IBOutlet var pwTextFieldContainer: PWView!
    @IBOutlet var invisibleImgView: PWImageView!
    
    @IBOutlet var mnemonicTextView: UITextView!
    @IBOutlet var mnemonicTextViewContainer: PWView!
    
    @IBOutlet var errMsgContainerView: UIView!
    @IBOutlet var invisibleBtn: UIButton!
    @IBOutlet var continueBtn: PWButton!
    
    var planet:Planet = Planet()
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        validateMnemonic(mnemonicTextView.text.components(separatedBy: " "))
    }
    
    override func viewInit() {
        super.viewInit()
        
        pwTextfield.delegate = self
        mnemonicTextView.delegate = self
    }
    
    override func setData() {
        super.setData()
        guard let userInfo = userInfo,
            let universeType = userInfo[Keys.UserInfo.universe] as? String else { return }
        
        if universeType == CoinType.BTC.name {
            planet.coinType = CoinType.BTC.coinType
        }
        else if universeType == CoinType.ETH.name {
            planet.coinType = CoinType.ETH.coinType
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedInvisible(_ sender: UIButton) {
        pwTextfield.isSecureTextEntry = !pwTextfield.isSecureTextEntry
        
        if pwTextfield.isSecureTextEntry {
            invisibleImgView.image = ThemeManager.currentTheme().invisibleImg
        }
        else {
            invisibleImgView.image = UIImage(named: "imageInputVisible")
        }
    }
    
    var importedPlanet:Planet?
    
    @IBAction func didTouchedContinue(_ sender: UIButton) {
        guard let coinType = planet.coinType else { return }
        
        if coinType == CoinType.BTC.coinType{
            importedPlanet = BitCoinManager.shared.importMnemonic(mnemonicPhrase: mnemonicTextView.text, passPhrase: pwTextfield.text ?? "", pinCode: PINCODE)
        }else if coinType == CoinType.ETH.coinType{
            importedPlanet = EthereumManager.shared.importMnemonic(mnemonicPhrase: mnemonicTextView.text, passPhrase: pwTextfield.text ?? "", pinCode: PINCODE)
        }
        
        if let planet = importedPlanet, let _ = planet.keyId {
            
            if let symbol = planet.symbol, let address = planet.address{
                Get(self).action(Route.URL("planet","search",symbol), requestCode: 0, resultCode: 0, data: ["q":address])
            }
            
        }
        else {
            Toast.init(text: "mnemonic_import_not_match_title".localized).show()
        }
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        
        if success {
            
            guard let planet = importedPlanet,
                let keyId = planet.keyId,
                let dict = dictionary,
                let returnVo = ReturnVO(JSON: dict),
                let results = returnVo.result as? Array<Dictionary<String, Any>> else { return }
            
            if PlanetStore.shared.get(keyId) != nil{
                Toast.init(text: "mnemonic_import_exists_title".localized).show()
                
            }else{
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
                    
                    sendAction(segue: Keys.Segue.MNEMONIC_IMPORT_TO_PLANET_NAME, userInfo: [Keys.UserInfo.planet: planet,
                                                                                            "isFromMain" : isFromMain])
                }
            }
        }
        
        
    }
    
    
    //MARK: - Private
    private func validateMnemonic(_ mnemonic: [String]) {
        let mnemonicService = ObjcMnemonicService()
        do {
            try mnemonicService.validateMnemonic(mnemonic: mnemonic)
            continueBtn.setEnabled(true, theme: currentTheme)
        }
        catch {
            continueBtn.setEnabled(false, theme: currentTheme)
        }
    }
    
}

//MARK: - UITextFieldDelegate
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

//MARK: - UITextViewDelegate
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
            let mnemonicArr = textView.text.components(separatedBy: " ")
            validateMnemonic(mnemonicArr)
            return false
        }
        
        return true
    }
}
