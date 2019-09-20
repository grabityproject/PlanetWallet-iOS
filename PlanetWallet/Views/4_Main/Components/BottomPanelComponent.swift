//
//  MainComponent.swift
//  PlanetWallet
//
//  Created by 박상은 on 19/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol BottomPanelDelegate {
    func didSwitched(_ mainItem: MainItem)
}

class BottomPanelComponent: ViewComponent, Themable {
    
    var delegate: BottomPanelDelegate?
    
    private let xibName = "BottomPanelComponent"
    
    @IBOutlet var blurView: PWBlurView!
    @IBOutlet var imageIcon: PWImageView!
    @IBOutlet var labelBalance: PWLabel!
    @IBOutlet var labelUnit: PWLabel!
    @IBOutlet var labelName: PWLabel!
    @IBOutlet var erc20Lb: UILabel!
    
    @IBOutlet var btnNext: PWImageView!
    
    private var tokenIndex:Int = 0;
    
    private var planet:Planet?;
    var mainItem:MainItem? {
        didSet {
            guard let mainItem = self.mainItem else { return }
            delegate?.didSwitched(mainItem)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func controller(_ controller: PlanetWalletViewController) {
        super.controller(controller)
    }
    
    func onClick(){
        if let planet = planet, let coinType = planet.coinType{
            if( CoinType.of(coinType).coinType == CoinType.ETH.coinType ){
                if let _ = mainItem, let _ = planet.items{
                    switchMainItemForETH()
                }
            }
        }
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame = self.bounds
        self.backgroundColor = .clear
        self.addSubview(view)
        
        imageIcon.cornerRadius = imageIcon.frame.width/2.0
    }
    
    func setTheme(_ theme: Theme) {
        blurView.setTheme(theme)
    }
    
    func setPlanet(_ planet:Planet ){
        
        guard let coinType = planet.coinType else { return }
        
        if CoinType.of(coinType).coinType == CoinType.BTC.coinType {
            
            if let item = planet.getMainItem(){
                self.setMainItem(item)
            }
            
        }else if CoinType.of(coinType).coinType == CoinType.ETH.coinType {

            if( self.planet == nil ){
                
                self.planet = planet
                if let item = planet.getMainItem(){
                    self.setMainItem(item)
                }
                
            }else{
                
                if( self.planet?.keyId != planet.keyId ){
                    
                    tokenIndex = 0
                    
                }else{
                    
                    if let items = planet.items {
                        
                        // Catch Index Out of bounds
                        setMainItem(items[tokenIndex])
                    }
                    
                }
                
            }
        }
        
        self.planet = planet
    }
    
    func setMainItem(_ mainItem:MainItem ){
        self.mainItem = mainItem
        
        if( mainItem.getCoinType() == CoinType.BTC.coinType ){
            
            imageIcon.image = UIImage(named: "imageTransferConfirmationBtc02")
            labelName.text = CoinType.BTC.coinName
            labelUnit.text = CoinType.BTC.name
            
            labelBalance.text = CoinNumberFormatter.short.toMaxUnit(balance: mainItem.getBalance(), coinType: CoinType.BTC)
            
            btnNext.isHidden = true
            erc20Lb.isHidden = true
            
        }else if( mainItem.getCoinType() == CoinType.ETH.coinType ){
            
            imageIcon.image = UIImage(named: "eth")
            labelName.text = CoinType.ETH.coinName
            labelUnit.text = CoinType.ETH.name
            labelBalance.text = CoinNumberFormatter.short.toMaxUnit(balance: mainItem.getBalance(), coinType: CoinType.ETH)
            
            btnNext.isHidden = false
            erc20Lb.isHidden = true
            
            tokenIndex = 0;
            
        }else if( mainItem.getCoinType() == CoinType.ERC20.coinType ){
            
            if let imgPath = mainItem.img_path {
                imageIcon.loadImageWithPath(Route.URL(imgPath))
            }
            
            labelName.text = mainItem.name
            labelUnit.text = mainItem.symbol
            labelBalance.text = CoinNumberFormatter.short.convertUnit(balance: mainItem.getBalance(), from: 0, to: Int(mainItem.decimals ?? "18")!)
            
            btnNext.isHidden = false
            erc20Lb.isHidden = false
        }
        
    }
    
    func switchMainItemForETH(){
        
        guard let planet = planet, let items = planet.items else { return }
        
        var changed = false;
        
        tokenIndex = tokenIndex + 1;
        if ( tokenIndex >= items.count ) {
            tokenIndex = 0;
        }
        
        for i in tokenIndex..<items.count{
            
            if CoinType.of(items[i].getCoinType()).coinType == CoinType.ETH.coinType{
                
                setMainItem(items[i])
                changed = true
                break
                
            }else if CoinType.of(items[i].getCoinType()).coinType == CoinType.ERC20.coinType{
                
                tokenIndex = i
                
                let item = items[i]
                if item.getBalance( ) != "" && item.getBalance( ) != "0" {
                    setMainItem(items[i])
                    changed = true
                    break
                }

            }
            
        }
        
        
        if ( changed ) {
            return;
        }
        switchMainItemForETH( );
    }
    
}
