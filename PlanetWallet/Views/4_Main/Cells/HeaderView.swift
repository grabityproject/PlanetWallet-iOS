//
//  HeaderView.swift
//  PlanetWallet
//
//  Created by 박상은 on 19/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class HeaderView: ViewComponent , Themable{
    
    private let xibName = "HeaderView"
    
    var statusHeight: CGFloat { return Utils.shared.statusBarHeight() }
    var naviBar:NavigationBar?
    var tableView:UITableView?
    
    var refreshComponent:RefreshAnimationComponent!
    
    @IBOutlet weak var planetView: PlanetView!
    @IBOutlet weak var labelName: PWLabel!
    @IBOutlet weak var labelAddress: PWLabel!
    @IBOutlet weak var btnCopy: UIButton!
    
    @IBOutlet weak var groupBackground: UIView!
    @IBOutlet weak var planetBackground: PlanetView!
    @IBOutlet weak var shadowDark: GradientView!
    @IBOutlet weak var shadowLight: GradientView!
    
    
    var planet:Planet?{
        didSet{
            if let planet = planet, let address = planet.address {
                planetBackground.data = address
                planetView.data = address
                labelAddress.text = Utils.shared.trimAddress(address)
                labelName.text = planet.name
            }
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
        self.naviBar = findViewById("navibar") as? NavigationBar
        self.tableView = findViewById("table_main") as? UITableView
    }

    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.frame = self.bounds
        self.backgroundColor = .clear
        self.addSubview(view)
    }
    
    @IBAction func btnCopyDidTouched(_ sender: Any) {
        if let planet = planet, let address = planet.address {
            UIPasteboard.general.string = address
            Toast(text: "main_copy_to_clipboard".localized).show()
        }
    }
    
    func setTheme(_ theme: Theme) {
        shadowDark.isHidden = theme != .DARK;
        shadowLight.isHidden = !shadowDark.isHidden;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if let tableView = tableView, let naviBar = naviBar{
            let offsetY = ( tableView.contentOffset.y + self.statusHeight + scrollView.contentInset.top )
            
            if( tableView.contentOffset.y > planetView.frame.origin.y + planetView.frame.height/3.0 - naviBar.frame.height ){
                let startPosition = (  planetView.frame.origin.y + planetView.frame.height/3.0 + self.statusHeight + scrollView.contentInset.top - naviBar.frame.height)
                let moveRange = planetView.frame.height*2.0/3.0
                let movePosition = offsetY - startPosition
                naviBar.backgroundView.alpha = movePosition / moveRange
            }else{
                naviBar.backgroundView.alpha = 0
            }

            if( offsetY > 0){
                groupBackground.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            }else{
                let scale = 1.0 - (offsetY - refreshComponent.refreshHeight)/(SCREEN_WIDTH/2.0)*0.5
                groupBackground.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            }
            
        }
    }
   
}
