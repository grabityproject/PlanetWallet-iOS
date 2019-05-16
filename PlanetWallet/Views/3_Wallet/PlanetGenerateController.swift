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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewInit()
        setData()
    }
    
    override func viewInit() {
        super.viewInit()
    }

    @IBAction func didTouchedRefresh(_ sender: UIButton) {
        //TODO: change planet
        planetView.data = "Test"
        planetBgView.data = "Test"
    }
    
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        
    }
    
    @IBAction func didTouchedClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
