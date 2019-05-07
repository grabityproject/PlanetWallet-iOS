//
//  CharPad.swift
//  PlanetWallet
//
//  Created by grabity on 03/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol CharPadDelegate: class {
    //Character Pad에서 버튼을 눌렀을 때
    func didTouchedCharPad(_ char: String)
    //Character Pad에서 delete버튼을 눌렀을 때 (isBack: 숫자패드로 돌아가는지)
    func didTouchedDeleteKeyOnCharPad(_ isBack: Bool)
}

class CharPad: UIView {

    weak var delegate: CharPadDelegate?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var charBtnList: [UIButton]!
    
    private var charDataList = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","Y","X","Z"]
    private var pw_char = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CharPad", owner: self, options: nil)
        
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(containerView)
        
        setKeyPad()
    }
    
    public func setKeyPad() {
        
        let shuffledCharDataList = charDataList.shuffled()
        
        for (idx,btn) in charBtnList.enumerated() {
            btn.setTitle(shuffledCharDataList[idx], for: .normal)
        }
    }
    
    public func resetPassword() {
        pw_char = ""
    }
    
    @IBAction func didTouchedCharPad(_ sender: UIButton) {
        if pw_char.count > 1 { return }
        else {
            if let selectedChar = sender.titleLabel?.text {
                delegate?.didTouchedCharPad(selectedChar)
            }
        }
    }
    
    @IBAction func didTouchedDeleteBtnOnCharPad(_ sender: UIButton) {
        if pw_char.count == 0 {
            delegate?.didTouchedDeleteKeyOnCharPad(true)
        }
        else {
            delegate?.didTouchedDeleteKeyOnCharPad(false)
        }
        
    }
}
