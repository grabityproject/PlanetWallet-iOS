//
//  MainComponent.swift
//  PlanetWallet
//
//  Created by 박상은 on 19/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class BottomPanelComponent: ViewComponent, Themable {
    
    private let xibName = "BottomPanelComponent"
    
    @IBOutlet var blurView: PWBlurView!
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var labelBalance: PWLabel!
    @IBOutlet var labelUnit: PWLabel!
    @IBOutlet var labelName: PWLabel!
    
    @IBOutlet var btnNext: PWImageView!
    
    private var tokenIndex:Int = 0;
    
    private var planet:Planet?;
    private var mainItem:MainItem?;
    
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
            
            let item = BTC()
            item.balance = planet.balance ?? "0"
            self.setMainItem(item)
            
        }else if CoinType.of(coinType).coinType == CoinType.ETH.coinType {

            if( self.planet == nil ){
                
                let item = ETH()
                item.balance = planet.balance ?? "0"
                self.setMainItem(item)
                
            }else{
                
                if( self.planet?.keyId != planet.keyId ){
                    
                    let item = ETH()
                    item.balance = planet.balance ?? "0"
                    self.setMainItem(item)
                    
                }else{
                    
                    if let mainItem = mainItem{
                        
                        if( CoinType.of(mainItem.getCoinType()).coinType == CoinType.ETH.coinType ){
                            
                            let item = ETH()
                            item.balance = planet.balance ?? "0"
                            self.setMainItem(item)
                            
                        }else if( CoinType.of(mainItem.getCoinType()).coinType == CoinType.ERC20.coinType ){
                            
                            if let items = planet.items{

                                setMainItem(items[tokenIndex])
                                
                            }
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
        self.planet = planet
    }
    
    func setMainItem(_ mainItem:MainItem ){
        self.mainItem = mainItem
        
        if( type(of: mainItem) == BTC.self ){
            
            let item:BTC = mainItem as! BTC
            
            imageIcon.image = UIImage(named: "imageTransferConfirmationBtc02")
            labelName.text = CoinType.BTC.coinName
            labelUnit.text = CoinType.BTC.name
            labelBalance.text = item.balance
            
            btnNext.isHidden = true
        
        }else if( type(of: mainItem) == ETH.self ){
            
            let item:ETH = mainItem as! ETH

            imageIcon.image = UIImage(named: "eth")
            labelName.text = CoinType.ETH.coinName
            labelUnit.text = CoinType.ETH.name
            labelBalance.text = item.balance
            
            btnNext.isHidden = false
            
            tokenIndex = 0;
            
        }else if( type(of: mainItem) == ERC20.self ){
            
            let item:ERC20 = mainItem as! ERC20
            
            imageIcon.downloaded(from: Route.URL(item.img_path!))
            labelName.text = item.name
            labelUnit.text = item.symbol
            labelBalance.text = item.balance
            
            btnNext.isHidden = false
            
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
                
                let item = items[i] as! ERC20
                if let balance = item.balance{
                    if balance != "" || balance != "0" {
                        
                        setMainItem(items[i])
                        changed = true
                        break
                        
                    }
                }
            }
            
        }
        
        
        if ( changed ) {
            return;
        }
        switchMainItemForETH( );
    }
    
}
