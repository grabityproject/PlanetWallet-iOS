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
        case MNEMONIC, JSON, PRIVATEKEY
    }
}

class WalletImportController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var mnemonicBtn: PWButton!
    @IBOutlet var jsonBtn: PWButton!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container_to_walletImportPage" {
            walletImportPageController = segue.destination as? WalletImportPageController
        }
    }

    //MARK: - IBAction
    @IBAction func didTouchedMenu(_ sender: UIButton) {
        if sender.tag == Menu.MNEMONIC.rawValue {
            selectedMenu = .MNEMONIC
        }
        else if sender.tag == Menu.JSON.rawValue {
            selectedMenu = .JSON
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
            
            mnemonicBtn.backgroundColor = currentTheme.backgroundColor
            mnemonicBtn.setTitleColor(currentTheme.mainText, for: .normal)
            mnemonicBtn.titleLabel?.font = Utils.shared.planetFont(style: .BOLD, size: 14)
            
            jsonBtn.backgroundColor = currentTheme.backgroundColor
            jsonBtn.setTitleColor(currentTheme.detailText, for: .normal)
            jsonBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
            
            privateKeyBtn.backgroundColor = currentTheme.backgroundColor
            privateKeyBtn.setTitleColor(currentTheme.detailText, for: .normal)
            privateKeyBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
        case .JSON:
            indicatorLeftAnchorConstraint.constant = (mnemonicBtn.frame.width * 1)
            
            mnemonicBtn.backgroundColor = currentTheme.backgroundColor
            mnemonicBtn.setTitleColor(currentTheme.detailText, for: .normal)
            mnemonicBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
            
            jsonBtn.backgroundColor = currentTheme.backgroundColor
            jsonBtn.setTitleColor(currentTheme.mainText, for: .normal)
            jsonBtn.titleLabel?.font = Utils.shared.planetFont(style: .BOLD, size: 14)
            
            privateKeyBtn.backgroundColor = currentTheme.backgroundColor
            privateKeyBtn.setTitleColor(currentTheme.detailText, for: .normal)
            privateKeyBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
        case .PRIVATEKEY:
            indicatorLeftAnchorConstraint.constant = (mnemonicBtn.frame.width * 2)
            
            mnemonicBtn.backgroundColor = currentTheme.backgroundColor
            mnemonicBtn.setTitleColor(currentTheme.detailText, for: .normal)
            mnemonicBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
            
            jsonBtn.backgroundColor = currentTheme.backgroundColor
            jsonBtn.setTitleColor(currentTheme.detailText, for: .normal)
            jsonBtn.titleLabel?.font = Utils.shared.planetFont(style: .REGULAR, size: 14)
            
            privateKeyBtn.backgroundColor = currentTheme.backgroundColor
            privateKeyBtn.setTitleColor(currentTheme.mainText, for: .normal)
            privateKeyBtn.titleLabel?.font = Utils.shared.planetFont(style: .BOLD, size: 14)
        }
    }
}

extension WalletImportController: WalletImportPageDelegate {
    func didScroll(offset: CGFloat) {
        self.indicatorLeftAnchorConstraint.constant = offset
    }
    
    func didMoveToPage(index: Int) {
        self.selectedMenu = Menu(rawValue: index) ?? .MNEMONIC
    }
}


extension WalletImportController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if let naviCon = navigationController {
            //from setting
            naviCon.popViewController(animated: true)
        }
        else {
            //from first sign in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
