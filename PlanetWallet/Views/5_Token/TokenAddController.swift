//
//  TokenAddController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

/*
 CutomTokenPage를 사용하지 않으므로
 사용은 하나 기능이 없는 Controller
 */

class TokenAddController: PlanetWalletViewController {

    enum Menu: Int {
        case ADD_TOKEN = 0
        case CUSTOM_TOKEN
    }
    @IBOutlet var naviBar: NavigationBar!
    
    @IBOutlet var addTokenMenuBtn: UIButton!
    @IBOutlet var customTokenMenuBtn: UIButton!
    @IBOutlet var menuBarIndicator: UIView!
    @IBOutlet var indicatorLeftAnchorConstraint: NSLayoutConstraint!
    
    private var tokenPageController: TokenPageController? {
        didSet {
            tokenPageController?.pageDelegate = self
            tokenPageController?.userInfo = self.userInfo
        }
    }
    
    var selectedMenu: Menu = .ADD_TOKEN {
        didSet {
            updateMenuBar()
        }
    }
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMenuBar()
    }
    
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
            
            addTokenMenuBtn.setMenuItemSelected(true, theme: currentTheme)
            customTokenMenuBtn.setMenuItemSelected(false, theme: currentTheme)
        case .CUSTOM_TOKEN:
            indicatorLeftAnchorConstraint.constant = addTokenMenuBtn.frame.width
            
            addTokenMenuBtn.setMenuItemSelected(false, theme: currentTheme)
            customTokenMenuBtn.setMenuItemSelected(true, theme: currentTheme)
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
        self.navigationController?.popViewController(animated: true)
    }
}

