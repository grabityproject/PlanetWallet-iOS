//
//  TopMenuCellCollectionViewCell.swift
//  PlanetWallet
//
//  Created by grabity on 23/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol TopMenuFooterDelegate {
    func didTouchedTopMenuFooter()
}

class TopMenuCell: UICollectionViewCell {
    
    var delegate: TopMenuFooterDelegate?
    
    @IBOutlet var containerView: PWView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var nameLb: PWLabel!
    @IBOutlet var universeLb: PWLabel!
    @IBOutlet var addImgView: PWImageView!
    @IBOutlet var footerSelectionBtn: UIButton!
    
    public var isFooterCell = false {
        didSet {
            self.addImgView.isHidden = false
            self.footerSelectionBtn.isHidden = false
            self.planetView.isHidden = true
            self.universeLb.isHidden = true
            self.nameLb.text = "Add New Planet"
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override var isSelected: Bool {
        didSet {
            self.containerView.backgroundColor = isSelected ? ThemeManager.currentTheme().border : UIColor.clear
        }
    }
    
    //MARK: - Private
    private func commonInit() {
        Bundle.main.loadNibNamed("TopMenuCell", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(containerView)
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedFooter(_ sender: UIButton) {
        delegate?.didTouchedTopMenuFooter()
    }
}
