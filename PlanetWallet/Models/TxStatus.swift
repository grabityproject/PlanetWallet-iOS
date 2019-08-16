//
//  TxStatus.swift
//  PlanetWallet
//
//  Created by grabity on 16/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

enum TxResults {
    case PENDING
    case CONFIRMED
}

enum TxDirection {
    case RECEIVED
    case SENT
}

struct TxStatus {
    var status: TxResults = .PENDING
    var direction: TxDirection = .RECEIVED
    
    init(currentPlanet: Planet, tx: Tx) {
        if let currentPlanetAddr = currentPlanet.address,
            let toAddress = tx.to,
            let fromAddress = tx.from,
            let status = tx.status
        {
            if status == "pending" {
                self.status = .PENDING
            }
            else {
                self.status = .CONFIRMED
            }
            
            if currentPlanetAddr == toAddress {
                direction = .RECEIVED
            }
            else if currentPlanetAddr == fromAddress {
                direction = .SENT
            }
        }
    }
}
