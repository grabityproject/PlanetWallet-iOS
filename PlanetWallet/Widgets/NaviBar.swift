//
//  NaviBar.swift
//  PlanetWallet
//
//  Created by grabity on 08/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
/*
protocol NaviBarDelegate_ {
    func didTouchedLeftBtn()
    func didTouchedRightBtn()
}

public enum LeftNaviItem{
    case BACK, CLOSE, MENU
}

class NaviBar: PWView {
    
    var delegate: NaviBarDelegate_?
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet var background: UIView!
    @IBOutlet private var titleLb: PWLabel!
    @IBOutlet private var separatorView: PWView!
    
    @IBOutlet var imageBack: PWImageView!
    @IBOutlet var imageClose: PWImageView!
    @IBOutlet var imagePlanet: PWImageView!
    
    @IBInspectable var title: String? {
        didSet {
            titleLb.text = title
        }
    }
    
    @IBInspectable var showSeparator: Bool = false {
        didSet {
            self.separatorView.isHidden = !showSeparator
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
        Bundle.main.loadNibNamed("NaviBar", owner: self, options: nil)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(containerView)
    }
    
    func setLeftButton( item:LeftNaviItem ){
        imageBack.isHidden = item != .BACK
        imageClose.isHidden = item != .CLOSE
        imagePlanet.isHidden = item != .MENU
    }
    
    @IBAction func didTouchedLeft(_ sender: UIButton) {
        delegate?.didTouchedLeftBtn()
    }
    
    @IBAction func didTouchedRight(_ sender: UIButton) {
        delegate?.didTouchedRightBtn()
    }
    
}
*/
