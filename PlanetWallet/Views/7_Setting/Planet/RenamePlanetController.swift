//
//  NicknameRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class RenamePlanetController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var nameTextfieldContainer: PWView!
    @IBOutlet var nameTextField: PWTextField!
    @IBOutlet var errLb: UILabel!
    @IBOutlet var saveBtn: PWButton!
    
    private var isValid = false {
        didSet {
            saveBtn.setEnabled(isValid, theme: settingTheme)
        }
    }
    
    var planet: Planet? {
        didSet {
            updatePlanetUI()
        }
    }

    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        nameTextField.delegate = self
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo, let planet = userInfo[Keys.UserInfo.planet] as? Planet{
            self.planet = planet
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSave(_ sender: UIButton) {
        if let planet = self.planet,
            let newName = nameTextField.text,
            let coinType = planet.coinType
        {
            let request = Planet()
            request.signature = Signer.sign(newName, privateKey: planet.getPrivateKey(keyPairStore: KeyPairStore.shared, pinCode: PINCODE))
            request.planet = newName
            request.address = planet.address
            Post(self).action(Route.URL("planet", CoinType.of(coinType).name), requestCode: 0, resultCode: 0, data:request.toJSON())
        }
    }
    
    //MARK: - Private
    private func updatePlanetUI() {
        if let planet = planet, let name = planet.name {
            nameTextField.placeholder = name
        }
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if let dict = dictionary{
            let response = ReturnVO(JSON: dict)
            if( response!.success! ){
                if let planet = planet {
                    planet.name = nameTextField.text
                    PlanetStore.shared.update(planet)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        
    }
}

extension RenamePlanetController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextfieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextfieldContainer.layer.borderColor = settingTheme.border.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else { return false }
        
        let newLength = textFieldText.utf16.count + string.utf16.count - range.length
        
        if newLength >= 1 {
            isValid = true
        }
        else {
            isValid = false
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameTextField.text = ""
        saveBtn.setEnabled(false, theme: settingTheme)
        nameTextField.resignFirstResponder()
        return false
    }
}

extension RenamePlanetController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
