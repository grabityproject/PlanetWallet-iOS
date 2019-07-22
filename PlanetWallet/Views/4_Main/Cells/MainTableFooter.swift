//
//  MainTableFooter.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol MainTableFooterDelegate {
    func didTouchedManageToken()
}

class MainTableFooter: UIView {

    var delegate: MainTableFooterDelegate?
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var manageTokenContainer: UIView!
    @IBOutlet var manageTokenBtnContainer: UIView!
    
    @IBOutlet var tokenManagenmentLb: PWLabel!
    @IBOutlet var btcTransactionEmptyMsgLb: PWLabel!
    @IBOutlet var tokenManagementContainerWidthConstraint: NSLayoutConstraint!
    
    public var isEthUniverse = true {
        didSet {
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
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MainTableFooter", owner: self, options: nil)
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

    private func updateUI() {
        if isEthUniverse {
            manageTokenContainer.isHidden = false
            btcTransactionEmptyMsgLb.isHidden = true
        }
        else {
            manageTokenContainer.isHidden = true
            btcTransactionEmptyMsgLb.isHidden = false
        }
    }
    
    @IBAction func didTouchedManageToken(_ sender: UIButton) {
        delegate?.didTouchedManageToken()
    }
    
}
