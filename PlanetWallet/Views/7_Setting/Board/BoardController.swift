//
//  AnnouncementsController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension BoardController {
    enum Category {
        case ANNOUNCEMENTS, WALLET, PLANET, UNIVERSE, SECURITY, TRANSFER
        
        func localized() -> String {
            switch self {
            case .ANNOUNCEMENTS:    return "setting_announcements_title".localized
            case .WALLET:           return "@@Wallet"
            case .PLANET:           return "setting_planet_title".localized
            case .UNIVERSE:         return "setting_universe_title".localized
            case .SECURITY:         return "setting_security_title".localized
            case .TRANSFER:         return "tx_list_header_btn_transfer_title".localized
            }
        }
        
        func urlParam() -> String {
            switch self {
            case .ANNOUNCEMENTS:    return "notice"
            case .WALLET:           return ""
            case .PLANET:           return ""
            case .UNIVERSE:         return ""
            case .SECURITY:         return ""
            case .TRANSFER:         return ""
            }
        }
        
        func cellHeight() -> CGFloat {
            switch self {
            case .ANNOUNCEMENTS:
                return 80.0
            case .WALLET, .PLANET, .UNIVERSE, .SECURITY, .TRANSFER:
                return 60.0
            }
        }
    }
}

class BoardController: PlanetWalletViewController {

    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var tableView: UITableView!
    let cellID = "noticecell"
    var datasource = [Board]()
    
    var section: Category = .ANNOUNCEMENTS
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        if let userInfo = userInfo,
            let value = userInfo["section"] as? Category {
            self.section = value
        }
        else {
            self.section = .ANNOUNCEMENTS
        }
        
        naviBar.title = section.localized()
        naviBar.delegate = self
        tableView.register(NoticeCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func setData() {
        
        Get(self).action(Route.URL("board", self.section.urlParam(), "list"), requestCode: 0, resultCode: 0, data: nil)
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
        
        if section == .WALLET {
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
