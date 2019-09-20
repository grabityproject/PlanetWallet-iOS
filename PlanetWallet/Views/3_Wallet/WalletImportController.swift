//
//  WalletImportController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension WalletImportController {
    enum Menu: Int {
        case MNEMONIC, PRIVATEKEY
    }
}

class WalletImportController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var mnemonicBtn: PWButton!
    @IBOutlet var privateKeyBtn: PWButton!
    @IBOutlet var indicatorLeftAnchorConstraint: NSLayoutConstraint!
    
    private var walletImportPageController: WalletImportPageController?
    
    var selectedMenu: Menu = .MNEMONIC {
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
        
        walletImportPageController?.pageDelegate = self
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container_to_walletImportPage" {
            walletImportPageController = segue.destination as? WalletImportPageController
            walletImportPageController?.userInfo = self.userInfo
        }
    }

    //MARK: - IBAction
    @IBAction func didTouchedMenu(_ sender: UIButton) {
        if sender.tag == Menu.MNEMONIC.rawValue {
            selectedMenu = .MNEMONIC
        }
        else {
            selectedMenu = .PRIVATEKEY
        }
        
        if let moveToVC = walletImportPageController?.orderedViewControllers[selectedMenu.rawValue] {
            walletImportPageController?.currentPageIdx = selectedMenu.rawValue
            walletImportPageController?.setViewControllers([moveToVC],
                                                    direction: .forward,
                                                    animated: false,
                                                    completion: nil)
        }
    }
    
    //MARK: - Private
    private func updateMenuBar() {
        switch selectedMenu {
        case .MNEMONIC:
            indicatorLeftAnchorConstraint.constant = (mnemonicBtn.frame.width * 0)
            
            mnemonicBtn.setMenuItemSelected(true, theme: currentTheme)
            privateKeyBtn.setMenuItemSelected(false, theme: currentTheme)
        case .PRIVATEKEY:
            indicatorLeftAnchorConstraint.constant = (mnemonicBtn.frame.width * 1)

            mnemonicBtn.setMenuItemSelected(false, theme: currentTheme)
            privateKeyBtn.setMenuItemSelected(true, theme: currentTheme)
        }
    }
}

//MARK: - WalletImportPageDelegate
extension WalletImportController: WalletImportPageDelegate {
    func didScroll(offset: CGFloat) {
        self.indicatorLeftAnchorConstraint.constant = offset
    }
    
    func didMoveToPage(index: Int) {
        self.selectedMenu = Menu(rawValue: index) ?? .MNEMONIC
    }
}

//MARK: - NavigationBarDelegate
extension WalletImportController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        self.dismissDetail()
    }
}
