//
//  BlinkingTextView.swift
//  PlanetWallet
//
//  Created by grabity on 12/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol BlinkingTextViewDelegate {
    func didEndEditing(_ textView: BlinkingTextView)
    func didBeginEditing(_ textView: BlinkingTextView)
}

class BlinkingTextView: UITextView, UITextViewDelegate {
    
    @IBInspectable var maximumLine = 2
    @IBInspectable var maximumCharacters: Int {
        return PlanetNameController.MAX_COUNT_OF_NAME
    }
    
    var delegateBlinking: BlinkingTextViewDelegate?
    
    //MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        self.delegate = self
        self.textContainer.maximumNumberOfLines = self.maximumLine
        self.textContainer.lineBreakMode = .byTruncatingTail
        
        self.inputView = UIView()
        self.becomeFirstResponder()
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(blinkingTextFieldTapped(_:)))
        self.addGestureRecognizer(tapGuesture)
        if let oldValue = self.text {
            self.text = oldValue + " "
        }
    }
    
    @objc func blinkingTextFieldTapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            
            if self.text.last == " " {
                self.text = String(self.text.dropLast())
            }
            
            self.endEditing(true)
            self.inputView = nil
            self.becomeFirstResponder()
        }
    }
    
    //MARK: - TextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        delegateBlinking?.didEndEditing(self)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        delegateBlinking?.didBeginEditing(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        //input type : alphabet, decimal, underbar
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9_].*", options: [])
            if regex.firstMatch(in: text, options: [], range: NSMakeRange(0, text.count)) != nil {
                return false
            }
        }
        catch {
            print("ERROR")
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= self.maximumCharacters
    }
}

