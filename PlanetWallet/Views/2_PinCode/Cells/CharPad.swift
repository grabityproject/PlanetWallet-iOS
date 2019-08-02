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
    func didTouchedDeleteBtn()
}

class CharPad: UIView {

    weak var delegate: CharPadDelegate?
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var charBtnList: [PWButton]!
    
    private var charDataList = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","Y","X","Z"]
    
    
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
    
    @IBAction func didTouchedChar(_ sender: UIButton) {
        if let selectedChar = sender.titleLabel?.text {
            delegate?.didTouchedCharPad(selectedChar)
        }
    }
    
    @IBAction func didTouchedDeleteBtn(_ sender: UIButton) {
        delegate?.didTouchedDeleteBtn()
    }
}
