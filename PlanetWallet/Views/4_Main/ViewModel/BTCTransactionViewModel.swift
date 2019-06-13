//
//  BTCTransactionViewModel.swift
//  PlanetWallet
//
//  Created by grabity on 13/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

class BTCTransactionViewModel {
    let transaction: BTCTransaction!
    
    init(_ transaction: BTCTransaction) {
        self.transaction = transaction
    }
    
    var name: String {
        switch transaction.direction {
        case .IN_COMING:    return transaction.from
        case .OUT_COMING:   return transaction.to
        }
    }
    
    var directionImg: UIImage? {
        switch transaction.direction {
        case .IN_COMING:    return UIImage(named: "imgeaBtcIncrease")
        case .OUT_COMING:   return UIImage(named: "imageBtcDiscrease")
        }
    }
    
    var amount: String {
        //0.1111 (소수점 4자리까지)
        return String(transaction.amount.rounded(4))
    }
    
    var date: String {
        if let dateStr = Utils.shared.getStringFromDate(transaction.date, format: .MMMddHHmm) {
            return dateStr
        }
        return ""
    }
}
