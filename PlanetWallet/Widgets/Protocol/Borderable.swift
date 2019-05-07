//
//  Bordable.swift
//  PlanetWallet
//
//  Created by grabity on 03/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol Borderable where Self: UIView {
    func toBorder(width: CGFloat, color: UIColor)
}

extension Borderable {
    func toBorder(width: CGFloat, color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
}
