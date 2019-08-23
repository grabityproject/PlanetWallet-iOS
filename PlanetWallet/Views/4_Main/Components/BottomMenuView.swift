//
//  BottomMeneView.swift
//  PlanetWallet
//
//  Created by 박상은 on 03/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import QRCode

/*
 Coin(ETH / BTC)과 관련된 팝업뷰
 */
class BottomMenuView: ViewComponent {
    
    @IBOutlet var qrCodeImgView: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var addressLb: UILabel!
    @IBOutlet var planetNameLb: UILabel!
    @IBOutlet var coinNameLb: UILabel!
    
    @IBOutlet var copyTopConstraint: NSLayoutConstraint!
    
    var planet:Planet?
    var token: ERC20? {
        didSet {
            if let token = token, let tokenName = token.name {
                self.coinNameLb.text = tokenName
            }
            else {
                if let coinType = planet?.coinType {
                    self.coinNameLb.text = CoinType.of(coinType).coinName
                }
            }
        }
    }
    
    var launcher:BottomMenuLauncher?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    //MARK: - Interface
    public func setPlanet(_ planet: Planet) {
        self.planet = planet

        if let planetName = planet.name, let address = planet.address, let coinType = planet.coinType {
            self.planetNameLb.text = planetName
            self.planetView.data = address
            self.addressLb.text = address
            self.qrCodeImgView.image = QRCode(address)?.image
            
            self.coinNameLb.text = CoinType.of(coinType).coinName
            
        }
    }
    
    //MARK: - Private
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
            Utils.shared.copyToClipboard(addr)
            Toast(text: "main_copy_to_clipboard".localized).show()
        }
    }
    
    @IBAction func didTouchedSend(_ sender: UIButton) {
        if let launcher = launcher{
            launcher.hide()
        }
        if let planet = planet, let controller = controller{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                controller.sendAction(segue: Keys.Segue.MAIN_TO_TRANSFER,
                                      userInfo: [Keys.UserInfo.planet: planet,
                                                 Keys.UserInfo.erc20: self.token as Any])
            }
        }

    }
}
