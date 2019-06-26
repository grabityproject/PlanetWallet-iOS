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
    @IBOutlet var darkGradientView: GradientView!
    @IBOutlet var lightGradientView: GradientView!
    @IBOutlet var nameTextView: BlinkingTextView!
    
    var tapGestureRecognizer: UITapGestureRecognizer?
    
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
        nameTextView.delegateBlinking = self
        
    }
    
    override func setData() {
        super.setData()
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedRefresh(_ sender: UIButton) {
        //TODO: change planet
        let randomStr = NSUUID().uuidString
        planetView.data = randomStr
        planetBgView.data = randomStr
    }
    
    @IBAction func didTouchedSelect(_ sender: UIButton) {
        guard let fromSegueID = userInfo?[Keys.UserInfo.fromSegue] as? String else { return }
        
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
    
    @objc func didTap() {
        self.view.endEditing(true)
    }
    
    //MARK: - Notification
    override func keyboardWillShow(notification: NSNotification) {
        if let tapGesture = tapGestureRecognizer {
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        if let tapGesture = tapGestureRecognizer {
            view.removeGestureRecognizer(tapGesture)
        }
    }
}

extension PlanetGenerateController: BlinkingTextViewDelegate {
    
    func didEndEditing(_ textView: BlinkingTextView) {
        
    }
    
    func didBeginEditing(_ textView: BlinkingTextView) {
        
    }
}
