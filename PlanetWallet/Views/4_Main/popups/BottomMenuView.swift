//
//  BottomMeneView.swift
//  PlanetWallet
//
//  Created by 박상은 on 03/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import QRCode

protocol BottomMenuDelegate {
    func didTouchedCopy(_ addr: String)
    func didTouchedSend()
}

class BottomMenuView: UIView {

    var delegate: BottomMenuDelegate?
    
    @IBOutlet var qrCodeImgView: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var addressLb: UILabel!
    @IBOutlet var amountLb: UILabel!
    @IBOutlet var coinTypeLb: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("BottomMenuView", owner: self, options: nil)
        containerView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: containerView.frame.height)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.layer.cornerRadius = 25
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.masksToBounds = true
        self.addSubview(containerView)
        
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: containerView.frame.height)
        
        var qrCode = QRCode("ansrbthd")
        qrCode?.errorCorrection = .High
        self.qrCodeImgView.image = qrCode?.image
        
    }
    
    @IBAction func didTouchedCopy(_ sender: UIButton) {
        if let addr = addressLb.text {
            UIPasteboard.general.string = addr
            delegate?.didTouchedCopy(addr)
        }
    }
    
    @IBAction func didTouchedSend(_ sender: UIButton) {
        delegate?.didTouchedSend()
    }
}
