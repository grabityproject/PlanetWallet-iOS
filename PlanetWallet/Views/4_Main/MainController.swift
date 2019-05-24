//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

enum Universe {
    case ETH
    case BTC
}

class MainController: PlanetWalletViewController {

    var universe: Universe = .ETH
    
    @IBOutlet var bgPlanetContainer: UIView!
    @IBOutlet var bgPlanetContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet var bgPlanetView: PlanetView!
    @IBOutlet var dimGradientView: GradientView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    
    @IBOutlet var naviBar: NavigationBar!
    var rippleView: UIView!
    
    var dataSources: [UITableViewDataSource] = []
    let ethDataSource = ETHCoinDataSource()
    let btcDataSource = BTCTransactionDataSource()
    
    var topMenuLauncher: TopMenuLauncher?
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Ripple animation transition
        UIView.animate(withDuration: 0.4, animations: {
            self.rippleView.alpha = 0
            self.rippleView.layer.cornerRadius = 0
            self.rippleView.bounds = CGRect(x: 25, y: 25, width: 0, height: 0)
        })
        
        self.topMenuLauncher = TopMenuLauncher(triggerView: naviBar.rightImageView)
        topMenuLauncher?.delegate = self
        
//        dimGradientView.setTheme(theme: currentTheme)
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        configureTableView()
        createRippleView()
    }
    
    override func setData() {
        super.setData()
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        topMenuLauncher?.setTheme(theme)
        dimGradientView.setTheme(theme: theme)
    }
    
    //MARK: - Private
    private func configureTableView() {
        tableView.register(ETHCoinCell.self, forCellReuseIdentifier: ethDataSource.cellID)
        tableView.register(BTCTransactionCell.self, forCellReuseIdentifier: btcDataSource.cellID)
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.5)
        
        ethDataSource.coinList = [Coin(), Coin()]
        ethDataSource.delegate = self
        btcDataSource.transactionList = [BTCTransaction(), BTCTransaction()]
        dataSources = [ethDataSource, btcDataSource]
        tableView.dataSource = dataSources[0]
    }
    
    private func createRippleView() {
        self.rippleView = UIView(frame: CGRect(x: 31, y: naviBar.leftImageView.frame.origin.y + naviBar.leftImageView.frame.height/2.0, width: 0, height: 0))
        rippleView.alpha = 0
        rippleView.backgroundColor = settingTheme.backgroundColor
        rippleView.layer.cornerRadius = 0
        rippleView.layer.masksToBounds = true
        self.view.addSubview(rippleView)
    }
    
    private func updateUniverse() {
        switch universe {
        case .ETH:
            universe = .BTC
            tableView.dataSource = dataSources[1]
            naviBar.title = "BTC"
            footerView.isHidden = true
        case .BTC:
            universe = .ETH
            tableView.dataSource = dataSources[0]
            naviBar.title = "ETH"
            footerView.isHidden = false
        }
        
        tableView.reloadData()
    }
}

extension MainController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        switch sender {
        case .LEFT:
            //Ripple animation transition
            UIView.animate(withDuration: 0.4, animations: {
                self.rippleView.alpha = 1
                let rippleViewMaxRadius = self.view.bounds.height * 2.0 * 1.4
                self.rippleView.layer.cornerRadius = rippleViewMaxRadius / 2
                self.rippleView.bounds = CGRect(x: 31,
                                                y: self.naviBar.leftImageView.frame.origin.y + self.naviBar.leftImageView.frame.height/2.0,
                                                width: rippleViewMaxRadius,
                                                height: rippleViewMaxRadius)
            }) { (isSuccess) in
                if isSuccess {
                    //perform segue
                    self.sendAction(segue: Keys.Segue.MAIN_TO_SETTING, userInfo: nil)
                }
            }
            
        case .RIGHT:
            updateUniverse()
        }
    }
}

extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = tableView.contentOffset.y
        
        if offsetY < 0 {
            let scale = 1 + ((-offsetY) * 2 / bgPlanetContainer.frame.height)
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        }
        else {
            print(bgPlanetContainerTopConstraint.constant - offsetY)
            bgPlanetContainer.frame.origin = CGPoint(x: bgPlanetContainer.frame.origin.x,
                                                     y: bgPlanetContainerTopConstraint.constant - offsetY)
        }
    }
}

extension MainController: ETHCoinCellDelegate {
    func didSelected(index: IndexPath) {
        print(index)
    }
}

extension MainController: MenuLauncherDelegate {
    func didSelected() {
        print("top menu selected")
    }
}
