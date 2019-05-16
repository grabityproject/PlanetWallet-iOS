//
//  PhoneRegistrationController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

struct DialCode: Mappable {
    var name: String?
    var code: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        code <- map["dial_code"]
    }
}

class PhoneRegistrationController: PlanetWalletViewController {

    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var phoneTextFieldContainer: PWView!
    @IBOutlet var phoneTextField: PWTextField!
    @IBOutlet var sendBtn: PWButton!
    
    @IBOutlet var codeContainer: UIView!
    @IBOutlet var codeTextField: PWTextField!
    @IBOutlet var codeTextFieldContainer: PWView!
    @IBOutlet var dialCodeLb: UILabel!
    
    @IBOutlet var timeLb: UILabel!
    
    @IBOutlet var okBtn: PWButton!
    
    private var isValid = false {
        didSet {
            okBtn.setEnabled(isValid, theme: settingTheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        phoneTextField.delegate = self
        codeTextField.delegate = self
    }
    
    @IBAction func didTouchedSend(_ sender: UIButton) {
        if codeContainer.isHidden {
            codeContainer.isHidden = false
        }
    }
    
    @IBAction func didTouchedDialCode(_ sender: UIButton) {
        guard let url = URL(string: "https://grabity.io/resources/web/dialcode.json") else { return }
        /*
        Alamofire.request(url).responseJSON { (response) in
            
            var returnVO: NSDictionary = response.result.value as! NSDictionary;
            
            if( (returnVO.value(forKey: "success") as! Bool) ){
                if( returnVO.value(forKey: "result") is NSArray ){
                    var result:NSArray = returnVO.value(forKey: "result") as! NSArray
                    print(( result[0] as! NSDictionary ).value(forKey: "code"))
                    
                }
            }
        }
         */
        
        Alamofire.request(url)
            .validate()
            .responseArray(keyPath: "result") {
                (response: DataResponse<[DialCode]>) in
            switch response.result {
            case .success(let codeList):
                let popup = PopupCountryCode(dataSource: codeList)
                popup.show(controller: self)
                
                //Touched Handler
                popup.handler = { [weak self] (dialCode) in
                    guard let strongSelf = self else { return }
                    strongSelf.dialCodeLb.text = dialCode?.code
                    popup.dismiss()
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}

extension PhoneRegistrationController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}

extension PhoneRegistrationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.tag == 1 else { return }
        
        codeTextFieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
        self.isValid = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.tag == 1 else { return }
        
        codeTextFieldContainer.layer.borderColor = settingTheme.border.cgColor
        self.isValid = false
    }
}
