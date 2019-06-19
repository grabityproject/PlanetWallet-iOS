//
//  UniverseType.swift
//  PlanetWallet
//
//  Created by grabity on 05/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

enum UniverseType {
    case ETH
    case BTC
    
    func description() -> String {
        switch self {
        case .ETH:      return "ETH Universe"
        case .BTC:      return "BTC Universe"
        }
    }
    
    func getUnit() -> String {
        switch self {
        case .ETH:      return "ETH"
        case .BTC:      return "BTC"
        }
    }
    
    func getIconImg(_ theme: Theme) -> UIImage? {
        switch self {
        case .ETH:
            if theme == .DARK {
                return UIImage(named: "imageTransferEthGray")
            }
            else {
                return UIImage(named: "imageTransferEthBlue")
            }
        case .BTC:
            if theme == .DARK {
                return UIImage(named: "imageTransferBtcGray")
            }
            else {
                return UIImage(named: "imageTransferBtcBlue")
            }
        }
    }
}

