//
//  Extension + UILabel.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

/*
 let range:NSRange?
 if let text = textToFind{
 range = self.mutableString.range(of: text, options: .caseInsensitive)
 }else{
 range = NSMakeRange(0, self.length)
 }
 if range!.location != NSNotFound {
 addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range!)
 }
 */

extension UILabel {
    func setColoredAddress(_ font: UIFont = Utils.shared.planetFont(style: .SEMIBOLD, size: 18)!) {
        guard let text = self.text else { return }
        let effectColor = UIColor(red: 255, green: 0, blue: 80)
        
        let attrText = NSMutableAttributedString(string: text)
        if text[0..<2] == "0x" { //ETH
            attrText.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: effectColor,
                                  range: NSMakeRange(2, 4))
            attrText.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: effectColor,
                                  range: NSMakeRange(text.count - 4, 4))
        }
        else { //Others
            attrText.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: effectColor,
                                  range: NSMakeRange(0, 4))
            attrText.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: effectColor,
                                  range: NSMakeRange(text.count - 4, 4))
        }
        attrText.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, text.count))
        self.attributedText = attrText
    }
}
