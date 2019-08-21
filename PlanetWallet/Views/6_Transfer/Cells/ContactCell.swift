//
//  ContactCell.swift
//  PlanetWallet
//
//  Created by grabity on 17/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol ContactCellDelegate {
    func didTouchedDelete(indexPath: IndexPath)
}

class ContactCell: PWTableCell {
    
    var delegate: ContactCellDelegate?
    
    @IBOutlet private var containerView: PWView!
    @IBOutlet public var planetView: PlanetView!
    @IBOutlet public var planetName: PWLabel!
    @IBOutlet public var addressLb: PWLabel!
    
    @IBOutlet var deleteImgView: PWImageView!
    @IBOutlet var deleteBtn: UIButton!
    var isRecentSearch = false {
        didSet {
            if self.isRecentSearch {
                deleteImgView.isHidden = false
                deleteBtn.isHidden = false
            }
            else {
                deleteImgView.isHidden = true
                deleteBtn.isHidden = true
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        
        Bundle.main.loadNibNamed("ContactCell", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        self.addSubview(containerView)
    }
    
    @IBAction func didTouchedDelete(_ sender: UIButton) {
        
        if let tableView = self.superview as? UITableView,
            let indexPath = tableView.indexPath(for: self)
        {
            delegate?.didTouchedDelete(indexPath: indexPath)
        }
    }
    
}
