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
    func didTouchedDelete()
}

class NumberPad: UIView {

    weak var delegate: NumberPadDelegate?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var numBtnList: [PWButton]!
    @IBOutlet var pointBtn: UIButton!
    
    // key pad에 .(point)가 필요한지
    public var shouldPoint: Bool = false {
        didSet {
            if shouldPoint {
                pointBtn.setTitle(".", for: .normal)
                pointBtn.isEnabled = true
                setKeyPad(true)
            }
            else {
                pointBtn.setTitle("", for: .normal)
                pointBtn.isEnabled = false
                setKeyPad(false)
            }
        }
    }
    
    private var numberDataList = [1,2,3,4,5,6,7,8,9,0]
    
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

    public func setKeyPad(_ isArranged: Bool = false) {
        if isArranged {
            for (idx,btn) in numBtnList.enumerated() {
                btn.setTitle("\(numberDataList[idx])", for: .normal)
            }
        }
        else {
            let shuffledNumberDataList = numberDataList.shuffled()
            for (idx,btn) in numBtnList.enumerated() {
                btn.setTitle("\(shuffledNumberDataList[idx])", for: .normal)
            }
        }
    }
    
    @IBAction func didTouchedNumPad(_ sender: UIButton) {
        
        if sender.tag == 1 {    // Delete button
            delegate?.didTouchedDelete()
        }
        else {
            if let selectedNumber = sender.titleLabel?.text {
                delegate?.didTouchedNumberPad(selectedNumber)
            }
        }
    }

    
}
