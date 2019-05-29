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
    
    private var firedTime = 180 {
        didSet {
            let min = firedTime / 60
            let sec = firedTime % 60
            timeLb.text = String(format: "%2d:%02d", min, sec)
        }
    }
    var timer = Timer()
    
    private var isValid = false {
        didSet {
            okBtn.setEnabled(isValid, theme: settingTheme)
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
        phoneTextField.delegate = self
        codeTextField.delegate = self
    }
    
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.firedTime > 0 {
                self.firedTime -= 1
                self.startTimer()
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedOK(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTouchedSend(_ sender: UIButton) {
        if codeContainer.isHidden {
            codeContainer.isHidden = false
            
            startTimer()
        }
    }
    
    @IBAction func didTouchedDialCode(_ sender: UIButton) {
        self.phoneTextField.resignFirstResponder()
        self.codeTextField.resignFirstResponder()
        
        self.fetchDialCode { (dialCodeList) in
            let popup = PopupCountryCode(dataSource: dialCodeList)
            popup.show(controller: self)
            
            //Touched Handler
            popup.handler = { [weak self] (dialCode) in
                guard let strongSelf = self else { return }
                strongSelf.dialCodeLb.text = dialCode?.code
                popup.dismiss()
            }
        }
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
    }
    
    //MARK: - Network
    private func fetchDialCode(completion: @escaping ([DialCode]) -> Void) {
        guard let url = URL(string: "https://grabity.io/resources/web/dialcode.json") else { return }
        
        Alamofire.request(url)
            .validate()
            .responseArray(keyPath: "result") {
                (response: DataResponse<[DialCode]>) in
                switch response.result {
                case .success(let codeList):
                    completion(codeList)
                case .failure(let err):
                    print(err.localizedDescription)
                }
        }
    }
    
    private func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: (#selector(updateTimer)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func updateTimer() {
        if firedTime < 1 {
            timer.invalidate()
        } else {
            firedTime -= 1
        }
    }
}

extension PhoneRegistrationController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PhoneRegistrationController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.tag == 1 else { return }
        
        codeTextFieldContainer.layer.borderColor = settingTheme.borderPoint.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.tag == 1 else { return }
        
        codeTextFieldContainer.layer.borderColor = settingTheme.border.cgColor
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
        textField.text = ""
        sendBtn.setEnabled(false, theme: settingTheme)
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
