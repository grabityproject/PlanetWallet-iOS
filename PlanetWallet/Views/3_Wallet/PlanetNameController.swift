//
//  PlanetNameController.swift
//  PlanetWallet
//
//  Created by grabity on 04/06/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetNameController: PlanetWalletViewController {
    @IBOutlet var planetBgView: PlanetView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var darkGradientView: GradientView!
    @IBOutlet var lightGradientView: GradientView!
    @IBOutlet var nameTextView: BlinkingTextView!
    
    //MARK: - Init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if( ThemeManager.currentTheme() == .DARK ){
            darkGradientView.isHidden = false
            lightGradientView.isHidden = true
        }else{
            darkGradientView.isHidden = true
            lightGradientView.isHidden = false
        }
    }
    
    override func viewInit() {
        super.viewInit()
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        performSegue(withIdentifier: Keys.Segue.MAIN_UNWIND, sender: nil)
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
