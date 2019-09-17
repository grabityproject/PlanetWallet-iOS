//
//  AdvancedGasView.swift
//  PlanetWallet
//
//  Created by grabity on 19/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol AdvancedGasViewDelegate {
    func didTouchedSave(_ gasPrice: String, gasLimit: String)
}

class AdvancedGasView: UIView {

    var delegate: AdvancedGasViewDelegate?
    
    private static let GWEI:String = "1000000000"
    private static let ETH_DEFAULT_GAS_LIMIT:String = "21000"
    private static let ETH_DEFAULT_GAS_PRICE:String = "20"
    private static let ERC20_DEFAULT_GAS_LIMIT:String = "100000"
    private static let ERC20_DEFAULT_GAS_PRICE:String = "10"

    var mainItem = MainItem()
    var ethAmount = Decimal()   //Wei
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var drawerView: UIView!
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var dimView: UIView!
    @IBOutlet var gasPriceContainer: PWView!
    @IBOutlet var gasPriceLb: UILabel!
    @IBOutlet var gasLimitLb: UILabel!
    
    @IBOutlet var gasLimitContainer: PWView!
    @IBOutlet var gasFeesLb: UILabel!
    
    @IBOutlet var keyPad: UIView!
 
    var drawerPanGesture: UIPanGestureRecognizer!
    var backgroundPanGesture: UIPanGestureRecognizer!
    
    private var inputText:String = String()
    
    var hasGasPriceFocus = true {
        didSet {
            if hasGasPriceFocus {
                if let gasStr = gasPriceLb.text {
                    self.inputText = gasStr
                }
                
                self.gasPriceContainer.layer.borderColor = UIColor.black.cgColor
                self.gasLimitContainer.layer.borderColor = UIColor(red: 237, green: 237, blue: 237).cgColor
                self.gasPriceLb.textColor = UIColor.black
                self.gasLimitLb.textColor = UIColor(red: 170, green: 170, blue: 170)
            }
            else {
                if let gasLimitStr = gasLimitLb.text {
                    self.inputText = gasLimitStr
                }
                
                self.gasLimitContainer.layer.borderColor = UIColor.black.cgColor
                self.gasPriceContainer.layer.borderColor = UIColor(red: 237, green: 237, blue: 237).cgColor
                self.gasPriceLb.textColor = UIColor(red: 170, green: 170, blue: 170)
                self.gasLimitLb.textColor = UIColor.black
            }
        }
    }
    
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
   
        setTheme(ThemeManager.currentTheme())
    }
    
    //MARK: - Interface
    public func show() {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: 0,
                                y: 0,
                                width: SCREEN_WIDTH,
                                height: SCREEN_HEIGHT)
            self.reset()
        }
        hasGasPriceFocus = true
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
        
        inputText = ""
        
        if mainItem.getCoinType() == CoinType.ETH.coinType {
            gasPriceLb.text = AdvancedGasView.ETH_DEFAULT_GAS_PRICE
            gasLimitLb.text = AdvancedGasView.ETH_DEFAULT_GAS_LIMIT
        }
        else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            gasPriceLb.text = AdvancedGasView.ERC20_DEFAULT_GAS_PRICE
            gasLimitLb.text = AdvancedGasView.ERC20_DEFAULT_GAS_LIMIT
        }
        
        setTextFee()
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
    
    private func calculateFee(gas: String?, limit: String?) -> Decimal? {
        guard let gasLimitStr = gas,
            let gasLimitDec = Decimal(string: gasLimitStr),
            let gasPriceStr = limit,
            let gasPriceDec = Decimal(string: gasPriceStr) else { return nil }
        
        return gasPriceDec * gasLimitDec
    }
    
    private func tooLargeFee() -> Bool {
        guard let fee = calculateFee(gas: gasPriceLb.text, limit: gasLimitLb.text)?.toString(),
            let feeWeiStr = CoinNumberFormatter.full.convertUnit(balance: fee, from: 9, to: 0),
            let feeWei = Decimal(string: feeWeiStr) else { return false }
    
        
        if ethAmount < feeWei {
            return true
        }
        else {
            return false
        }
    }
    
    private func isZeroGasPrice() -> Bool {
        guard let gasPriceStr = gasPriceLb.text else { return false }
        if gasPriceStr == "" { return true }
        else { return false }
    }
    
    private func tooLowGasLimit() -> Bool {
        guard let gasLimitStr = gasLimitLb.text, let gasLimitDec = Decimal(string: gasLimitStr) else { return false }
        var maxGasLimit: Decimal = 21000
        
        if mainItem.getCoinType() == CoinType.ETH.coinType {
            maxGasLimit = 21000
        }
        else if mainItem.getCoinType() == CoinType.ERC20.coinType {
            maxGasLimit = 100000
        }
        
        if gasLimitDec < maxGasLimit {
            return true
        }
        else {
            return false
        }
    }
    
    private func isValidValues() -> Bool {
       return !( tooLargeFee( ) || tooLowGasLimit( ) || isZeroGasPrice( ) )
    }
    
    private func setTextFee() {
        if let feeGwei = calculateFee(gas: gasPriceLb.text, limit: gasLimitLb.text)?.toString(),
            let feeETH = CoinNumberFormatter.full.convertUnit(balance: feeGwei, from: 9, to: 18)
        {
            gasFeesLb.text = "Fees: " + feeETH + " ETH"
        }
        else {
            gasFeesLb.text = "Fees: -"
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSave(_ sender: UIButton) {
        
        guard let gasLimitStr = gasLimitLb.text,
            let gasPriceStr = gasPriceLb.text,
            let gasPriceWei = CoinNumberFormatter.full.convertUnit(balance: gasPriceStr, from: 9, to: 0) else {
                Toast(text: "eth_fee_popup_gas_check_title".localized).show()
                return
        }
        
        if isValidValues() {
            delegate?.didTouchedSave(gasPriceWei, gasLimit: gasLimitStr)
            self.hide()
        }
        else {
            Toast(text: "eth_fee_popup_gas_check_title".localized).show()
        }
    }
    
    @IBAction func didTouchedCancel(_ sender: UIButton) {
        self.reset()
        self.hide()
    }
    
    @IBAction func didTouchedGasPrice(_ sender: UIButton) {
        //check valid GasLimit
        if tooLowGasLimit() {
            if mainItem.getCoinType() == CoinType.ETH.coinType {
                Toast(text: "eth_fee_popup_eth_minimun_gas_limit_error_title".localized).show()
            }
            else if mainItem.getCoinType() == CoinType.ERC20.coinType {
                Toast(text: "eth_fee_popup_erc_minimun_gas_limit_error_title".localized).show()
            }
        }
        else {
            hasGasPriceFocus = true
        }
    }
    
    @IBAction func didTouchedGasLimit(_ sender: UIButton) {
        //check valid GasPrice
        if isZeroGasPrice() {
            Toast(text: "eth_fee_popup_not_gas_zero_title".localized).show()
        }
        else {
            hasGasPriceFocus = false
        }
    }
    
    @IBAction func didTouchedKey(_ sender: UIButton) {
        
        if sender.tag == 99 {   //Delete btn
            inputText = String(inputText.dropLast())
        }
        else if let num = sender.titleLabel?.text, let _ = Int(num) {
            inputText += num
        }
        
        if hasGasPriceFocus {
            gasPriceLb.text = inputText
        }else {
            gasLimitLb.text = inputText
        }
        
        setTextFee()
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

