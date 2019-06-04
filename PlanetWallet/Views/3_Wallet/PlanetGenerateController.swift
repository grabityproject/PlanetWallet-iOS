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
    @IBOutlet var darkGradientView: GradientView!
    @IBOutlet var lightGradientView: GradientView!
    
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
        guard let fromSegueID = userInfo?["segue"] as? String else { return }
        print(fromSegueID)
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedRefresh(_ sender: UIButton) {
        //TODO: change planet
        let randomStr = NSUUID().uuidString
        planetView.data = randomStr
        planetBgView.data = randomStr
    }
    
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        guard let fromSegueID = userInfo?["segue"] as? String else { return }
        
        if fromSegueID == Keys.Segue.WALLET_ADD_TO_PLANET_GENERATE {
            performSegue(withIdentifier: Keys.Segue.MAIN_UNWIND, sender: nil)
        }
        else if fromSegueID == Keys.Segue.PINCODE_CERTIFICATION_TO_PLANET_GENERATE {
            performSegue(withIdentifier: Keys.Segue.PLANET_GENERATE_TO_MAIN, sender: nil)
        }
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
