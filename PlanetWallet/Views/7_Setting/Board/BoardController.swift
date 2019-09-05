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
        
        func param() -> String {
            switch self {
            case .Announcements: return "notice"
            case .FAQ:           return "faq"
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
    var datasource = [Board]()
    
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
    
    override func setData() {
        //category/list
        Get(self).action(Route.URL("board", self.section.param(), "list"), requestCode: 0, resultCode: 0, data: nil)
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard let dict = dictionary else { return }
        
        if let returnVO = ReturnVO(JSON: dict), let isSuccess = returnVO.success {
            if isSuccess {
                let items = returnVO.result as! Array<Dictionary<String, Any>>
                items.forEach { (item) in
                    //except self item
                    if let board = Board(JSON: item) {
                        datasource.append(board)
                    }
                }
                
                tableView.reloadData()
            }
            else {
                if let errDic = returnVO.result as? [String: Any],
                    let errorMsg = errDic["errorMsg"] as? String
                {
                    Toast(text: errorMsg).show()
                }
            }
        }
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
        
        let board = datasource[indexPath.row]
        cell.titleLb.text = board.subject
        
        if let date = board.created_at {
            cell.dateLb.text = Utils.shared.changeDateFormat(date: date,
                                                             beforFormat: .BASIC,
                                                             afterFormat: .yyyyMMdd)
        }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBoard = datasource[indexPath.row]
        sendAction(segue: Keys.Segue.BOARD_TO_DETAIL_BOARD, userInfo: ["board": selectedBoard,
                                                                       "section": self.section])
    }
    
}
