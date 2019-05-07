//
//  PlanetGenerateController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class PlanetGenerateController: UIViewController {

    @IBOutlet var planetViewBgContainer: UIView!
    @IBOutlet var planetViewContainer: UIView!
    var planetView: PlanetView?
    var planetViewBg: PlanetView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let dimViewBg = GradientView(frame: planetViewBgContainer.bounds)
//        dimViewBg.startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
//        dimViewBg.endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        dimViewBg.startLocation = 0
//        dimViewBg.endLocation = 1
//        dimViewBg.backgroundColor = .black
//        dimViewBg.startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
//        dimViewBg.lastColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
//        planetViewBg = PlanetView(frame: planetViewBgContainer.bounds)
//        planetViewBgContainer.addSubview(planetViewBg!)
//        planetViewBgContainer.addSubview(dimViewBg)
//
//        planetView = PlanetView(frame: planetViewContainer.bounds)
//        planetViewContainer.addSubview(planetView!)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
