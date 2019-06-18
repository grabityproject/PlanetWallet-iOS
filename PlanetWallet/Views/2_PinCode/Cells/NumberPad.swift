//
//  SignPad.swift
//  PlanetWallet
//
//  Created by grabity on 02/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol NumberPadDelegate: class {
    //Number Pad에서 버튼을 눌렀을 때
    func didTouchedNumberPad(_ num: String)
}

class NumberPad: UIView {

    weak var delegate: NumberPadDelegate?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var numBtnList: [PWButton]!
    
    private var numberDataList = [0,1,2,3,4,5,6,7,8,9]
    var pw_number = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NumberPad", owner: self, options: nil)
        
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
        
        setKeyPad()
    }

    public func setKeyPad() {
        
        let shuffledNumberDataList = numberDataList.shuffled()
        
        for (idx,btn) in numBtnList.enumerated() {
            btn.setTitle("\(shuffledNumberDataList[idx])", for: .normal)
        }
    }
    
    public func deleteLastPW() {
        pw_number = String(pw_number.dropLast())
    }
    
    public func resetPassword() {
        pw_number = ""
    }
    
    @IBAction func didTouchedNumPad(_ sender: UIButton) {
        if sender.tag == 1 {    // Delete button
            if pw_number.count < 1 { return }
            pw_number = String(pw_number.dropLast())
        }
        else {
            if let selectedNumber = sender.titleLabel?.text {
                pw_number = pw_number + selectedNumber
            }
        }
        delegate?.didTouchedNumberPad(pw_number)
    }

    
}
