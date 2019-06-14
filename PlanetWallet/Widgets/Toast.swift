//
//  Toast.swift
//  PlanetWallet
//
//  Created by grabity on 14/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

class ToastView: UIView {
    
    public var text: String? {
        get { return self.textLabel.text }
        set { self.textLabel.text = newValue }
    }
    @objc public dynamic var textInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
    
    private let backgroundView: UIView = {
        let `self` = UIView()
        self.backgroundColor = UIColor(red: 30, green: 30, blue: 40)
        self.alpha = 0.8
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        return self
    }()
    
    private let textLabel: UILabel = {
        let `self` = UILabel()
        self.textColor = .white
        self.backgroundColor = .clear
        self.font = Utils.shared.planetFont(style: .REGULAR, size: 16)
        self.numberOfLines = 0
        self.textAlignment = .center
        return self
    }()
    
    public init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.addSubview(self.backgroundView)
        self.addSubview(self.textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let window = UIApplication.shared.keyWindow else { return }
        let containerSize = window.frame.size
        let constraintSize = CGSize(
            width: containerSize.width * (280.0 / 320.0),
            height: CGFloat.greatestFiniteMagnitude
        )
        let textLabelSize = self.textLabel.sizeThatFits(constraintSize)
        self.textLabel.frame = CGRect(
            x: self.textInsets.left,
            y: self.textInsets.top,
            width: textLabelSize.width,
            height: textLabelSize.height
        )
        self.backgroundView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right,
            height: self.textLabel.frame.size.height + self.textInsets.top + self.textInsets.bottom
        )
        
        let backgroundViewSize = self.backgroundView.frame.size
        self.frame = CGRect(
            x: (containerSize.width - backgroundViewSize.width) * 0.5,
            y: (containerSize.height / 2) - backgroundViewSize.height - 30,
            width: backgroundViewSize.width,
            height: backgroundViewSize.height
        )
    }
    
}

class Toast: NSObject {
    public var text: String? {
        get { return self.view.text }
        set { self.view.text = newValue }
    }
    public var view: ToastView = ToastView()
    
    public init(text: String?) {
        super.init()
        self.text = text
    }
    
    open func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.alpha = 0
            
            window.addSubview(self.view)
            
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .beginFromCurrentState,
                animations: {
                    self.view.alpha = 1
            },
                completion: { completed in
                    UIView.animate(
                        withDuration: 1.5,
                        animations: {
                            self.view.alpha = 1.0001
                    },
                        completion: { completed in
                            UIView.animate(
                                withDuration: 0.5,
                                animations: {
                                    self.view.alpha = 0
                            },
                                completion: { completed in
                                    self.view.removeFromSuperview()
                            }
                            )
                    }
                    )
            }
            )
        }
    }
}
