//
//  AdvancedGasView.swift
//  PlanetWallet
//
//  Created by grabity on 19/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol AdvancedGasViewDelegate {
    func didTouchedSave(_ gas: Int, gasLimit: Int)
}

class AdvancedGasView: UIView {

    var delegate: AdvancedGasViewDelegate?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var dimView: UIView!
    @IBOutlet var gasTextField: PWTextField!
    @IBOutlet var gasTextFieldContainer: PWView!
    
    @IBOutlet var gasLimitTextField: PWTextField!
    @IBOutlet var gasLimitTextFieldContainer: PWView!
    
    var gasPrice = 20
    var gasLimit = 210000
    
    var backgroundTapGesture : UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AdvancedGasView", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        self.addSubview(containerView)
        
        contentView.layer.cornerRadius = 25
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.masksToBounds = true
        
        backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapAction));
        dimView.addGestureRecognizer(backgroundTapGesture)
        
        gasLimitTextField.delegate = self
        gasTextField.delegate = self
        
        setTheme(ThemeManager.currentTheme())
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
    }
    
    //MARK: - Interface
    public func show() {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: SCREEN_WIDTH,
                                height: SCREEN_HEIGHT)
        }
    }
    
    public func hide() {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: 0,
                                y: SCREEN_HEIGHT,
                                width: SCREEN_WIDTH,
                                height: SCREEN_HEIGHT)
        }
        self.endEditing(true)
    }
    
    public func reset() {
        self.gasTextField.text = "\(gasPrice)"
        self.gasLimitTextField.text = "\(gasLimit)"
    }

    @objc func backgroundTapAction(_ recognizer: UITapGestureRecognizer) {
        self.hide()
    }
    
    //MARK: - Private
    private func setTheme(_ theme: Theme) {
        if( theme == .LIGHT ){
            contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0).cgColor
            contentView.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
            contentView.layer.shadowRadius = 8
            contentView.layer.shadowOpacity = 0.2
            contentView.layer.masksToBounds = false
        }else{
            contentView.dropShadow(radius: 0, cornerRadius: 0)
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSave(_ sender: UIButton) {
        if let gas = Int(gasTextField.text!), let limit = Int(gasLimitTextField.text!) {
            delegate?.didTouchedSave(gas, gasLimit: limit)
        }
        
        self.hide()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if self.frame.origin.y == 0 {
                self.frame.origin.y = -keyboardHeight
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        print("keyboard will hide")
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if self.frame.origin.y != 0 {
                self.frame.origin.y += keyboardHeight
            }
        }
    }
}

extension AdvancedGasView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.gasTextFieldContainer.layer.borderColor = UIColor.black.cgColor
        }
        else {
            self.gasLimitTextFieldContainer.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.gasTextFieldContainer.layer.borderColor = UIColor(red: 237, green: 237, blue: 237).cgColor
        }
        else {
            self.gasLimitTextFieldContainer.layer.borderColor = UIColor(red: 237, green: 237, blue: 237).cgColor
        }
    }
}
