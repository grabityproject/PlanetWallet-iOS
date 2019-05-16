//
//  AnnouncementsController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension NoticeFAQController {
    enum Section {
        case Announcements, FAQ
        
        func description() -> String {
            switch self {
            case .Announcements: return "Announcements"
            case .FAQ:           return "FAQ"
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

class NoticeFAQController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var tableView: UITableView!
    let cellID = "noticecell"
    let datasource = ["announce1","event1", "announce2","announce3"]
    
    var section: Section = .Announcements {
        didSet {
            naviBar.title = section.description()
            tableView.reloadData()
        }
    }
    
    override func viewInit() {
        super.viewInit()
        
        if let userInfo = userInfo,
            let value = userInfo["section"] as? Section {
            self.section = value
        }
        
        naviBar.delegate = self
        tableView.register(NoticeCell.self, forCellReuseIdentifier: cellID)
    }
}

extension NoticeFAQController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: false)
        }
    }
}

extension NoticeFAQController: UITableViewDelegate, UITableViewDataSource {
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
    
}
