//
//  PlanetGenerateController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetGenerateController: PlanetWalletViewController {

    @IBOutlet var planetBgView: PlanetView!
    @IBOutlet var planetView: PlanetView!
    @IBOutlet var confirmLb: UILabel!
    @IBOutlet var planetNameLb: UILabel!
    @IBOutlet var gradientView: GradientView!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        gradientView.setTheme(theme: currentTheme)
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedRefresh(_ sender: UIButton) {
        //TODO: change planet
        let randomStr = NSUUID().uuidString
        planetView.data = randomStr
        planetBgView.data = randomStr
    }
    
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        if let _ = userInfo?["segue"] { //from main controller
            performSegue(withIdentifier: Keys.Segue.MAIN_UNWIND, sender: nil)
        }
        else {
            performSegue(withIdentifier: Keys.Segue.PLANET_GENERATE_TO_MAIN, sender: nil)
        }
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
