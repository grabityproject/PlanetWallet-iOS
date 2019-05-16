//
//  RenamePlanetController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class NicknameRegistrationController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var textFieldContainer: PWView!
    @IBOutlet var saveBtn: PWButton!
    
    private var isValid = false {
        didSet {
            saveBtn.setEnabled(isValid, theme: settingTheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        textField.delegate = self
    }
    
    override func setData() {
        super.setData()
    }

}

extension NicknameRegistrationController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}

extension NicknameRegistrationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
        self.isValid = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldContainer.layer.borderColor = settingTheme.border.cgColor
        self.isValid = false
    }
}

