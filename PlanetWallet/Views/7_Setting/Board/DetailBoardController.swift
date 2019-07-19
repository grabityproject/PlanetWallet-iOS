//
//  DetailAnnouncementsController.swift
//  PlanetWallet
//
//  Created by grabity on 13/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class DetailBoardController: PlanetWalletViewController {
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var boardSubjectLb: UILabel!
    @IBOutlet var boardDateLb: UILabel!
    
    override func viewInit() {
        super.viewInit()
        
        naviBar.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        if let userInfo = userInfo,
            let board = userInfo["board"] as? Board,
            let section = userInfo["section"] as? BoardController.Section,
            let date = board.created_at
        {
            naviBar.title = section.localized()
            boardSubjectLb.text = board.subject
            boardDateLb.text = Utils.shared.changeDateFormat(date: date,
                                                             beforFormat: .BASIC,
                                                             afterFormat: .yyyyMMdd)
        }
    }
}

extension DetailBoardController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            navigationController?.popViewController(animated: true)
        }
    }
}
