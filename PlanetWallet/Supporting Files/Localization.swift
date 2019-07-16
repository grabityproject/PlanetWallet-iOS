//
//  Localization.swift
//  PlanetWallet
//
//  Created by grabity on 15/07/2019.
//  Copyright © 2019 grabity. All rights reserved.
//
import Foundation
import UIKit

protocol Localizable {
    var localized: String { get }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            if( key != key?.localized ){
                text = key?.localized
            }
        }
    }
}
extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            setTitle(key?.localized, for: .normal)
        }
    }
}

extension NavigationBar: XIBLocalizable {
    @IBInspectable var xibLocKey: String? {
        get { return nil }
        set(key) {
            self.title = key?.localized
        }
    }
}
