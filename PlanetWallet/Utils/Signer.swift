//
//  Signer.swift
//  PlanetWallet
//
//  Created by grabity on 24/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation

class Signer {
    static func sign(_ msg: String, privateKey: String) -> String? {
        if let msgData = msg.data(using: .utf8),
            let privateKeyData = Data(hex: privateKey) {
            return Crypto.signer(hash: Crypto.sha256(msgData), privateKey: privateKeyData)
        }
        else {
            return nil
        }
    }
}
