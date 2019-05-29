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
    @IBOutlet var manateTokenBtnContainer: UIView!
    
    @IBOutlet var btcTransactionEmptyMsgLb: PWLabel!
    
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
        manateTokenBtnContainer.layer.addBorder(edges: [.left,.bottom,.right],
                                                color: theme.border,
                                                thickness: 1)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MainTableFooter", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(containerView)
        
        manateTokenBtnContainer.layer.addBorder(edges: [.left,.bottom,.right],
                                                color: ThemeManager.currentTheme().border,
                                                thickness: 1)
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
