//
//  TokenAddController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TokenAddController: PlanetWalletViewController {

    enum Menu: Int {
        case ADD_TOKEN = 0
        case CUSTOM_TOKEN
    }
    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var addTokenMenuView: UIView!
    @IBOutlet var AddTokenMenuBtn: UIButton!
    
    @IBOutlet var customTokenMenuView: UIView!
    @IBOutlet var customTokenMenuBtn: UIButton!
    
    private var tokenTabBarController: UITabBarController?
    
    var selectedMenu: Menu = .ADD_TOKEN {
        didSet {
            
            tokenTabBarController?.selectedIndex = selectedMenu.rawValue

            switch selectedMenu {
            case .ADD_TOKEN:
                addTokenMenuView.backgroundColor = currentTheme.mainText
                AddTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
                AddTokenMenuBtn.setTitleColor(currentTheme.mainText, for: .normal)
                
                customTokenMenuView.backgroundColor = currentTheme.backgroundColor
                customTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
                customTokenMenuBtn.setTitleColor(currentTheme.mainText, for: .normal)
            case .CUSTOM_TOKEN:
                addTokenMenuView.backgroundColor = currentTheme.backgroundColor//currentTheme.mainText
                AddTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
                AddTokenMenuBtn.setTitleColor(currentTheme.detailText, for: .normal)
                
                customTokenMenuView.backgroundColor = currentTheme.mainText
                customTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
                customTokenMenuBtn.setTitleColor(currentTheme.mainText, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit()
        setData()
    }
    
    override func viewInit() {
        super.viewInit()
        
        self.naviBar.delegate = self
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerViewSegue" {
            tokenTabBarController = segue.destination as? UITabBarController
        }
    }
    
    @IBAction func didTouchedMenubar(_ sender: UIButton) {
        
        if sender.tag == Menu.ADD_TOKEN.rawValue {
            selectedMenu = .ADD_TOKEN
        }
        else if sender.tag == Menu.CUSTOM_TOKEN.rawValue {
            selectedMenu = .CUSTOM_TOKEN
        }
    }

}


extension TokenAddController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        
    }
}

