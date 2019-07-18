//
//  TopMenuView.swift
//  PlanetWallet
//
//  Created by grabity on 23/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TopMenuView: PWView {

    let cellId = "topMenuCell"
    let footerID = "topMenuFooter"
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TopMenuView", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.layer.cornerRadius = 25
        containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        containerView.layer.masksToBounds = true
        self.addSubview(containerView)
        
        collectionView.register(TopMenuCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(TopMenuCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: footerID)
    }
}
