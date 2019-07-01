//
//  AdvancedGasView.swift
//  PlanetWallet
//
//  Created by grabity on 19/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: Int)
}

class AdvancedGasView: UIView {

    var delegate: AdvancedGasViewDelegate?
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var drawerView: UIView!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var dimView: UIView!
    @IBOutlet var gasPriceContainer: PWView!
    @IBOutlet var gasPriceBtn: UIButton!
    @IBOutlet var gasLimitBtn: UIButton!
    @IBOutlet var gasLimitContainer: PWView!
    @IBOutlet var gasFeesLb: UILabel!
    
    @IBOutlet var keyPad: UIView!
    
    var hasGasPriceFocus = true {
        didSet {
            if hasGasPriceFocus {
                if let gasStr = gasPriceBtn.titleLabel?.text {
                    self.inputText = gasStr
                }
                
                self.gasPriceContainer.layer.borderColor = UIColor.black.cgColor
                self.gasLimitContainer.layer.borderColor = UIColor(red: 237, green: 237, blue: 237).cgColor
                self.gasPriceBtn.setTitleColor(.black, for: .normal)
                self.gasLimitBtn.setTitleColor(UIColor(red: 170, green: 170, blue: 170), for: .normal)
            }
            else {
                if let gasLimitStr = gasLimitBtn.titleLabel?.text {
                    self.inputText = gasLimitStr
                }
                
                self.gasLimitContainer.layer.borderColor = UIColor.black.cgColor
                self.gasPriceContainer.layer.borderColor = UIColor(red: 237, green: 237, blue: 237).cgColor
                self.gasPriceBtn.setTitleColor(UIColor(red: 170, green: 170, blue: 170), for: .normal)
                self.gasLimitBtn.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    var inputText = "\(AdvancedGasView.DEFAULT_GAS_PRICE)" {
        didSet {
            print(inputText)
            if hasGasPriceFocus {
                gasPrice = inputText
            }
            else {
                gasLimit = inputText
            }
        }
    }
    
    var gasPrice: String = "\(AdvancedGasView.DEFAULT_GAS_PRICE)" {
        didSet {
            self.gasPriceBtn.setTitle(inputText, for: .normal)
            if let gas = Int(gasPrice), let limit = Int(gasLimit) {
                self.gasFeesLb.text = "Fees: \(Utils.shared.gweiToETH(calculateGasPrice(gas: gas, limit: limit))) ETH"
            }
        }
    }
    
    var gasLimit: String = "\(AdvancedGasView.DEFAULT_GAS_LIMIT)" {
        didSet {
            self.gasLimitBtn.setTitle(inputText, for: .normal)
            if let gas = Int(gasPrice), let limit = Int(gasLimit) {
                self.gasFeesLb.text = "Fees: \(Utils.shared.gweiToETH(calculateGasPrice(gas: gas, limit: limit))) ETH"
            }
        }
    }
    
    static let DEFAULT_GAS_PRICE = 20
    static let DEFAULT_GAS_LIMIT = 210000
    
    var drawerPanGesture: UIPanGestureRecognizer!
    var backgroundPanGesture: UIPanGestureRecognizer!
    
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
        
        drawerPanGesture = UIPanGestureRecognizer(target: self, action: #selector(drawerPanAction));
        drawerView.addGestureRecognizer(drawerPanGesture)
        backgroundPanGesture = UIPanGestureRecognizer(target: self, action: #selector(drawerPanAction));
        backgroundView.addGestureRecognizer(backgroundPanGesture)
        
        if let gas = Int(gasPrice), let limit = Int(gasLimit) {
            self.gasFeesLb.text = "Fees: \(Utils.shared.gweiToETH(calculateGasPrice(gas: gas, limit: limit))) ETH"
        }
        
        setTheme(ThemeManager.currentTheme())
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
        self.gasPriceBtn.setTitle("\(AdvancedGasView.DEFAULT_GAS_PRICE)", for: .normal)
        self.gasLimitBtn.setTitle("\(AdvancedGasView.DEFAULT_GAS_LIMIT)", for: .normal)
        self.hasGasPriceFocus = true
        self.inputText = "\(AdvancedGasView.DEFAULT_GAS_PRICE)"
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
    
    private func calculateGasPrice(gas: Int, limit: Int) -> Int {
        return gas * limit
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSave(_ sender: UIButton) {
        if gasPrice == "" || gasLimit == "" {
            Toast(text: "공백 x").show()
        }
        
        if let gas = Int(gasPrice),
            let limit = Int(gasLimit)
        {
            if gas > 0 && limit > 21000 {
                delegate?.didTouchedSave(calculateGasPrice(gas: gas, limit: limit))
                self.hide()
            }
            else {
                Toast(text: "최소 금액 x").show()
            }
        }
    }
    
    @IBAction func didTouchedCancel(_ sender: UIButton) {
        self.reset()
        self.hide()
    }
    
    @IBAction func didTouchedGasPrice(_ sender: UIButton) {
        hasGasPriceFocus = true
    }
    
    @IBAction func didTouchedGasLimit(_ sender: UIButton) {
        hasGasPriceFocus = false
    }
    
    @IBAction func didTouchedKey(_ sender: UIButton) {
        if sender.tag == 0 {
            guard let text = sender.titleLabel?.text else { return }
            inputText += text
        }
        else { //delete btn
            inputText = String(inputText.dropLast())
        }
    }
    
    
    @objc func drawerPanAction(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.changed {
            
            let movePoint : CGFloat  = recognizer.translation(in: dimView).y
            if movePoint > 0 {
                self.frame = CGRect(x: 0,
                                    y: movePoint,
                                    width: self.frame.width,
                                    height: self.frame.height)
            }
        }
        else if recognizer.state == UIGestureRecognizer.State.ended
        {
            let updownBorder = self.frame.height * 0.8
            let movePoint = recognizer.translation(in: self.dimView).y
            
            UIView.animate(withDuration: 0.2) {
                if( -updownBorder <  -self.frame.height + movePoint ){
                    self.frame = CGRect(x: 0,
                                        y: SCREEN_HEIGHT,
                                        width: self.frame.width,
                                        height: self.frame.height);

                }
                else {
                    self.frame = CGRect(x: 0,
                                        y: 0,
                                        width: self.frame.width,
                                        height: self.frame.height);
                }
            }
        }
    }
}

