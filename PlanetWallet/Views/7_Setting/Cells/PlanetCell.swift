//
//  PlanetCell.swift
//  PlanetWallet
//
//  Created by grabity on 09/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol PlanetCellDelegate {
    func didTouchedMoreBtn(indexPath: IndexPath)
}

class PlanetCell: UITableViewCell {

    var delegate: PlanetCellDelegate?
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var coinLb: PWLabel!
    @IBOutlet var planetNameLb: PWLabel!
    @IBOutlet var addressLb: PWLabel!
    @IBOutlet var moreBtn: UIButton!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PlanetCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
    }
    
    @IBAction func didTouchedMore(_ sender: UIButton) {
        
        if let tableView = self.superview as? UITableView,
            let indexPath = tableView.indexPath(for: self) {
            delegate?.didTouchedMoreBtn(indexPath: indexPath)
        }
    }
    
}
