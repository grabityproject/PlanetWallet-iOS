//
//  AdvancedGasView.swift
//  PlanetWallet
//
//  Created by grabity on 19/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: Decimal, gasLimit: Decimal)
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
    
    var inputText = "\(EthereumFeeInfo.DEFAULT_GAS_PRICE)" {
        didSet {

            if hasGasPriceFocus {
                gasPrice = inputText
            }
            else {
                gasLimit = inputText
            }
        }
    }
    
    var gasPrice: String = "\(EthereumFeeInfo.DEFAULT_GAS_PRICE)" {
        didSet {
            self.gasPriceBtn.setTitle(inputText, for: .normal)
            if let gas = Int(gasPrice), let limit = Int(gasLimit),
                let feeEther = CoinNumberFormatter.full.convertUnit(balance: String(calculateGasPrice(gas: gas, limit: limit)), from: .GWEI, to: .ETHER) {
                self.gasFeesLb.text = "fee_popup_fees_title".localized + " \(feeEther)) ETH"
            }
        }
    }
    
    var gasLimit: String = "\(21000)" {
        didSet {
            self.gasLimitBtn.setTitle(inputText, for: .normal)
            if let gas = Int(gasPrice), let limit = Int(gasLimit),
                let feeEther = CoinNumberFormatter.full.convertUnit(balance: String(calculateGasPrice(gas: gas, limit: limit)), from: .GWEI, to: .ETHER) {
                self.gasFeesLb.text = "fee_popup_fees_title".localized + " \(feeEther)) ETH"
            }
        }
    }
    
    public var gasInfo: EthereumFeeInfo? {
        didSet {
            if let gas = self.gasInfo {
                gasLimit = "\(gas.advancedGasLimit)"
                self.gasLimitBtn.setTitle(gasLimit, for: .normal)
            }
        }
    }
    
//    public var isERC20 = false {
//        didSet {
//            gasLimit = "\(DEFAULT_GAS_LIMIT)"
//            self.gasLimitBtn.setTitle("\(self.DEFAULT_GAS_LIMIT)", for: .normal)
//        }
//    }
    
//    static let DEFAULT_GAS_PRICE = 20
//    var DEFAULT_GAS_LIMIT: Int {
//        if isERC20 { return 100000 }
//        else { return 21000 }
//    }
    
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
        
        if let gas = Int(gasPrice), let limit = Int(gasLimit),
            let feeEther = CoinNumberFormatter.full.convertUnit(balance: String(calculateGasPrice(gas: gas, limit: limit)), from: .GWEI, to: .ETHER)
        {
            self.gasFeesLb.text = "fee_popup_fees_title".localized + " \(feeEther) ETH"
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
        if let gasInfo = gasInfo {
            self.gasPriceBtn.setTitle("\(EthereumFeeInfo.DEFAULT_GAS_PRICE)", for: .normal)
            self.gasLimitBtn.setTitle("\(gasInfo.advancedGasLimit)", for: .normal)
            self.hasGasPriceFocus = true
            self.inputText = "\(EthereumFeeInfo.DEFAULT_GAS_PRICE)"
        }
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
            Toast(text: "fee_popup_not_spaces_title".localized).show()
        }
        
        
        if let gasInfo = gasInfo,
            let gasPriceStr = CoinNumberFormatter.full.convertUnit(balance: gasPrice, from: .GWEI, to: .WEI),
            let gasPrice = Decimal(string: gasPriceStr),
            let gasLimit = Decimal(string: gasLimit)
        {
            if gasPrice > 0 && gasLimit >= gasInfo.advancedGasLimit {
                delegate?.didTouchedSave(gasPrice, gasLimit: gasLimit)
                self.hide()
            }
            else if gasPrice < 1 {
                Toast(text: "fee_popup_gas_price_least_title".localized).show()
            }
            else if gasLimit < 21000 {
                Toast(text: "fee_popup_gas_limit_least_title".localized).show()
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

