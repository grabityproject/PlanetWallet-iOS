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
    
    @IBOutlet var AddTokenMenuBtn: UIButton!
    @IBOutlet var customTokenMenuBtn: UIButton!
    @IBOutlet var menuBarIndicator: UIView!
    @IBOutlet var indicatorLeftAnchorConstraint: NSLayoutConstraint!
    
    private var tokenPageController: TokenPageController? {
        didSet {
            tokenPageController?.pageDelegate = self
        }
    }
    
    var selectedMenu: Menu = .ADD_TOKEN {
        didSet {
            updateMenuBar()
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        self.naviBar.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerViewSegue" {
            tokenPageController = segue.destination as? TokenPageController
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedMenubar(_ sender: UIButton) {
        if sender.tag == Menu.ADD_TOKEN.rawValue {
            selectedMenu = .ADD_TOKEN
        }
        else if sender.tag == Menu.CUSTOM_TOKEN.rawValue {
            selectedMenu = .CUSTOM_TOKEN
        }
        
        
        if let moveToVC = tokenPageController?.orderedViewControllers[selectedMenu.rawValue] {
            tokenPageController?.currentPageIdx = selectedMenu.rawValue
            tokenPageController?.setViewControllers([moveToVC],
                                                    direction: .forward,
                                                    animated: false,
                                                    completion: nil)
        }
    }

    //MARK: - Private
    private func updateMenuBar() {
        switch selectedMenu {
        case .ADD_TOKEN:
            indicatorLeftAnchorConstraint.constant = 0
            
            AddTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
            AddTokenMenuBtn.setTitleColor(currentTheme.mainText, for: .normal)
            AddTokenMenuBtn.titleLabel?.font = Utils.shared.planetFont(style: .BOLD, size: 14)
            
            customTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
            customTokenMenuBtn.setTitleColor(currentTheme.detailText, for: .normal)
            customTokenMenuBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
        case .CUSTOM_TOKEN:
            indicatorLeftAnchorConstraint.constant = AddTokenMenuBtn.frame.width
            
            AddTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
            AddTokenMenuBtn.setTitleColor(currentTheme.detailText, for: .normal)
            AddTokenMenuBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
            
            customTokenMenuBtn.backgroundColor = currentTheme.backgroundColor
            customTokenMenuBtn.setTitleColor(currentTheme.mainText, for: .normal)
            customTokenMenuBtn.titleLabel?.font = Utils.shared.planetFont(style: .BOLD, size: 14)
        }
    }
    
}

extension TokenAddController: TokenPageDelegate {
    func didScroll(offset: CGFloat) {
        self.indicatorLeftAnchorConstraint.constant = offset
    }
    
    func didMoveToPage(index: Int) {
        self.selectedMenu = Menu(rawValue: index) ?? .ADD_TOKEN
    }
}


extension TokenAddController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        
    }
}

