//
//  IntensityBlurVIew.swift
//  PlanetWallet
//
//  Created by 박상은 on 03/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class IntensityBlurVIew: UIVisualEffectView {
    private var animator: UIViewPropertyAnimator!
    
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
