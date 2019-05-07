//
//  Roundable.swift
//  PlanetWallet
//
//  Created by grabity on 03/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol Roundable where Self: UIView {
    func toRound(cornerRadius: CGFloat)
}

extension Roundable {
    func toRound(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}




