//
//  MainTableFooter.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class FooterView: ViewComponent {
    
    var tableView:UITableView?
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var manageTokenContainer: UIView!
    @IBOutlet var manageTokenBtnContainer: UIView!
    
    @IBOutlet var tokenManagenmentLb: PWLabel!
    @IBOutlet var btcTransactionEmptyMsgLb: PWLabel!
    @IBOutlet var tokenManagementContainerWidthConstraint: NSLayoutConstraint!
    
    var planet:Planet?{
        didSet{
           updateUI()
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
    
    public func setTheme(_ theme: Theme) {
        manageTokenBtnContainer.layer.borderColor = ThemeManager.currentTheme().border.cgColor
    }
    
    override func controller(_ controller: PlanetWalletViewController) {
        super.controller(controller)
        tableView = findViewById("table_main") as? UITableView
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FooterView", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(containerView)
        
        manageTokenBtnContainer.layer.borderColor = ThemeManager.currentTheme().border.cgColor
        manageTokenBtnContainer.layer.borderWidth = 1
        
        manageTokenBtnContainer.layer.cornerRadius = 8
        manageTokenBtnContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let maximumLabelSize: CGSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        let expectedLabelSize: CGSize = tokenManagenmentLb.sizeThatFits(maximumLabelSize)
        
        let newWidth = expectedLabelSize.width + (17 + 20 + 10 + 25)
        tokenManagenmentLb.frame.size = expectedLabelSize
        tokenManagementContainerWidthConstraint.constant = newWidth
    }
    
    func updateUI() {
        if let planet = planet, let coinType = planet.coinType{
            
            if CoinType.of(coinType).coinType == CoinType.ETH.coinType {
                
                manageTokenContainer.isHidden = false
                btcTransactionEmptyMsgLb.isHidden = true
                
            }else if CoinType.of(coinType).coinType == CoinType.BTC.coinType {
                
                manageTokenContainer.isHidden = true
                
                if let tableView = tableView{
                    
                    let sections = tableView.numberOfSections
                    var count = 0;
                    for i in 0..<sections{
                        count = count + tableView.numberOfRows(inSection: i)
                    }
                    
                    btcTransactionEmptyMsgLb.isHidden = count > 0
                }
                
            }else {
                
                manageTokenContainer.isHidden = true
                btcTransactionEmptyMsgLb.isHidden = true
                
            }
            
        }
        
    }
    
    @IBAction func didTouchedManageToken(_ sender: UIButton) {
        if let planet = planet, let controller = controller{
            controller.sendAction(segue: Keys.Segue.MAIN_TO_TOKEN_ADD,
                                  userInfo: [Keys.UserInfo.planet:planet])
        }
        
    }
    
}
