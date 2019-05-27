//
//  RefreshContents.swift
//  PlanetWallet
//
//  Created by grabity on 27/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import Lottie

class RefreshContents: UIView {

    @IBOutlet var containerView: UIView!
    private let animationView = AnimationView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        self.addSubview(containerView)
        
        self.animationView.animation = Animation.named("refreshAnim1")
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([animationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     animationView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                                     animationView.widthAnchor.constraint(equalToConstant: 60),
                                     animationView.heightAnchor.constraint(equalToConstant: 60)])
    }
    
    public func playAnimation() {
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce) { (isSuccess) in
            if isSuccess {
                
            }
        }
    }
}
