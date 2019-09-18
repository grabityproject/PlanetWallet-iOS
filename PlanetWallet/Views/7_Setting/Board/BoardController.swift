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
            case .WALLET:           return "service_wallet_title".localized
            case .PLANET:           return "service_planet_title".localized
            case .UNIVERSE:         return "service_universe_title".localized
            case .SECURITY:         return "service_security_title".localized
            case .TRANSFER:         return "service_transfer_title".localized
            }
        }
        
        func urlParam() -> String {
            switch self {
            case .ANNOUNCEMENTS:    return "notice"
            case .WALLET:           return "wallet"
            case .PLANET:           return "planet"
            case .UNIVERSE:         return "universe"
            case .SECURITY:         return "security"
            case .TRANSFER:         return "transfer"
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
    
    var adapter: BoardAdapter?
    
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
    }
    
    override func setData() {
        
        adapter = BoardAdapter(self.tableView, [])
        adapter?.delegates.append(self)
        
        switch section {
        case .ANNOUNCEMENTS:
            Get(self).action(Route.URL("board", self.section.urlParam(), "list"), requestCode: 0, resultCode: 0, data: nil)
        case .PLANET, .WALLET, .SECURITY, .TRANSFER, .UNIVERSE:
            Get(self).action(Route.URL("board", "service", "list"), requestCode: 0, resultCode: 0, data: ["value" : self.section.urlParam()])
        }
    }
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        guard success, let dict = dictionary else { return }
        
        var datasource = [Board]()
        
        if let returnVO = ReturnVO(JSON: dict), let isSuccess = returnVO.success {
            if isSuccess {
                let items = returnVO.result as! Array<Dictionary<String, Any>>
                items.forEach { (item) in
                    //except self item
                    if let board = Board(JSON: item) {
                        datasource.append(board)
                    }
                }
                
                adapter?.dataSetNotify(datasource)
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

extension BoardController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedBoard = adapter?.dataSource[indexPath.row] {
            sendAction(segue: Keys.Segue.BOARD_TO_DETAIL_BOARD, userInfo: ["board": selectedBoard,
                                                                           "section": self.section])
        }
    }
    
}
