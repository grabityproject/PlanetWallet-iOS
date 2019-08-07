//
//  PWTableCell.swift
//  PlanetWallet
//
//  Created by grabity on 20/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PWTableCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = ThemeManager.currentTheme().border
        }
        else {
            self.backgroundColor = .clear
        }
    }
    
    func commonInit() {
        self.selectionStyle = .none
    }
}
