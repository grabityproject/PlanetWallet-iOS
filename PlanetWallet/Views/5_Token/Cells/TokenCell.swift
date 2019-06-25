//
//  TokenCell.swift
//  PlanetWallet
//
//  Created by grabity on 07/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol TokenCellDelegate: class {
    func didSelected(indexPath: IndexPath)
}

class TokenCell: PWTableCell {

    @IBOutlet var containerView: PWView!
    @IBOutlet var iconImgView: UIImageView!
    @IBOutlet var nameLb: PWLabel!
    
    @IBOutlet var unCheckedView: PWView!
    @IBOutlet var checkedImgView: PWImageView!
    
    weak var delegate: TokenCellDelegate?
    
    override func commonInit() {
        super.commonInit()
        
        Bundle.main.loadNibNamed("TokenCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.backgroundColor = ThemeManager.currentTheme().backgroundColor
        addSubview(containerView)
    }
    
    @IBAction func didTouchedSelection(_ sender: UIButton) {

        if let tableView = self.superview as? UITableView,
           let indexPath = tableView.indexPath(for: self)
        {

            delegate?.didSelected(indexPath: indexPath )
        }
    }
    
}
