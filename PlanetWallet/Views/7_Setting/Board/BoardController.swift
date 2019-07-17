//
//  AnnouncementsController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension BoardController {
    enum Section {
        case Announcements, FAQ
        
        func localized() -> String {
            switch self {
            case .Announcements: return "setting_announcements_title".localized
            case .FAQ:           return "setting_faq_title".localized
            }
        }
        
        func cellHeight() -> CGFloat {
            switch self {
            case .Announcements:    return 80.0
            case .FAQ:              return 60.0
            }
        }
    }
}

class BoardController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var tableView: UITableView!
    let cellID = "noticecell"
    let datasource = ["announce1","event1", "announce2","announce3"]
    
    var section: Section = .Announcements {
        didSet {
            naviBar.title = section.localized()
            tableView.reloadData()
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        if let userInfo = userInfo,
            let value = userInfo["section"] as? Section {
            self.section = value
        }
        else {
            self.section = .Announcements
        }
        
        naviBar.delegate = self
        tableView.register(NoticeCell.self, forCellReuseIdentifier: cellID)
    }
}

extension BoardController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension BoardController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NoticeCell
        cell.titleLb.text = datasource[indexPath.row]
        if section == .FAQ {
            cell.dateLb.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return section.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
    }
    
}
