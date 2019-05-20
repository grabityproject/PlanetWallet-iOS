//
//  MainController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class MainController: PlanetWalletViewController {

    private let cellID = "coincell"
    
    @IBOutlet var bgPlanetContainer: UIView!
    @IBOutlet var bgPlanetView: PlanetView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var naviBar: NavigationBar!
    var rippleView: UIView!
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Ripple animation transition
        UIView.animate(withDuration: 0.4, animations: {
            self.rippleView.alpha = 0
            self.rippleView.layer.cornerRadius = 0
            self.rippleView.bounds = CGRect(x: 25, y: 25, width: 0, height: 0)
        })
    }
    
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        headerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT * 0.5)
        
        self.rippleView = UIView(frame: CGRect(x: 31, y: naviBar.leftImageView.frame.origin.y + naviBar.leftImageView.frame.height/2.0, width: 0, height: 0))
        rippleView.alpha = 0
        rippleView.backgroundColor = settingTheme.backgroundColor
        rippleView.layer.cornerRadius = 0
        rippleView.layer.masksToBounds = true
        self.view.addSubview(rippleView)
    }
    
    override func setData() {
        super.setData()
    }
}

extension MainController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        switch sender {
        case .LEFT:
            //Ripple animation transition
            UIView.animate(withDuration: 0.4, animations: {
                self.rippleView.alpha = 1
                self.rippleView.layer.cornerRadius = self.view.bounds.height * 2.0 * 1.4 / 2
                self.rippleView.bounds = CGRect(x: 31, y: self.naviBar.leftImageView.frame.origin.y + self.naviBar.leftImageView.frame.height/2.0, width: self.view.bounds.height * 2.0 * 1.4, height: self.view.bounds.height * 2.0 * 1.4)
            }) { (isSuccess) in
                if isSuccess {
                    //perform segue
                    self.sendAction(segue: Keys.Segue.MAIN_TO_SETTING, userInfo: nil)
                }
            }
            
        case .RIGHT:
            print("touched Right bar item")
        }
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = .clear

//        cell.alpha = 0
        cell.textLabel?.text = "test"
        cell.textLabel?.textColor = .white
        return cell
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 375))
//        headerView.backgroundColor = .red
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = tableView.contentOffset.y
        print(offsetY)
        if offsetY < 0
        {
            let maxOffsetY = tableView.contentSize.height - tableView.bounds.height - tableView.contentInset.bottom - (SCREEN_HEIGHT * 0.5)
            let percentage = offsetY / maxOffsetY
            
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: percentage + 1, y: percentage + 1)
        }
        else if offsetY == 0 {
            bgPlanetContainer.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            bgPlanetContainer.frame.origin = CGPoint(x: bgPlanetContainer.frame.origin.x, y: -150)
        }
        else
        {
            bgPlanetContainer.frame.origin = CGPoint(x: bgPlanetContainer.frame.origin.x, y: -150 - offsetY)
        }
    }
}

