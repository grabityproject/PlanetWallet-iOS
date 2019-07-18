//
//  TransferController.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit
import AVFoundation

extension TransferController {
    enum State {
        case DEFAULT
        case NOT_FOUND
        case RESULTS
    }
}

class TransferController: PlanetWalletViewController {

    var planet:Planet?
    var erc20: ERC20?
    
    var adapter : PlanetSearchAdapter?
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notFoundLb: PWLabel!
    @IBOutlet var pasteClipboardBtn: UIButton!
    @IBOutlet var magnifyingImgView: PWImageView!
    
    var search:String = ""
    
    var qrCaptureController: QRCaptureController?
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
        naviBar.title = "transfer_toolbar_title".localized
        
        if let placeHolderFont = Utils.shared.planetFont(style: .REGULAR, size: 14) {
            textField.attributedPlaceholder = NSAttributedString(string: "transfer_search_title".localized,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText,
                                                                              NSAttributedString.Key.font: placeHolderFont])
        }
    }
    
    override func setData() {
        
        if let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet
        {
            self.planet = planet
            
            adapter = PlanetSearchAdapter(tableView, []);
            adapter?.delegates.append(self)
            
            if let erc20 = userInfo[Keys.UserInfo.erc20] as? ERC20 {
                self.erc20 = erc20
            }
            
            updateUI()
        }
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        
        if let placeHolderFont = Utils.shared.planetFont(style: .REGULAR, size: 14) {
            textField.attributedPlaceholder = NSAttributedString(string: "transfer_search_title".localized,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText,
                                                                              NSAttributedString.Key.font: placeHolderFont])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? QRCaptureController {
            qrCaptureController = destination
            qrCaptureController?.delegate = self
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedPasteClipboard(_ sender: UIButton) {
        if let copiedStr = Utils.shared.getClipboard() {
            textField.text = copiedStr
            
            if let planet = self.planet, let coinType = planet.coinType{
                Get(self).action(Route.URL("planet", "search", CoinType.of(coinType).name ),requestCode: 0, resultCode: 0, data:["q":copiedStr] )
            }
        }
    }
    
    //MARK: - Private
    private func updateUI() {
        guard let planet = planet else { return }
        
        if let adapter = adapter {
            if( adapter.dataSource.count == 0 && search.count == 0 ){
                
                self.tableView.isHidden = true
                self.notFoundLb.isHidden = true
                
                if let pastedStr = Utils.shared.getClipboard(), let address = planet.address {
                    if EthereumManager.shared.validateAddress(pastedStr) && address != pastedStr {
                        self.pasteClipboardBtn.isHidden = false
                    }
                }
            }else if( adapter.dataSource.count == 0 && search.count != 0 ){
                
                self.tableView.isHidden = true
                self.notFoundLb.isHidden = false
                self.pasteClipboardBtn.isHidden = true
                
            }else{
                
                self.tableView.isHidden = false
                self.notFoundLb.isHidden = true
                self.pasteClipboardBtn.isHidden = true
                
            }
        }
    }
    
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
     
        if let dict = dictionary{
            if let returnVo = ReturnVO(JSON: dict){
                if( returnVo.success! ){
                    var results = Array<Planet>()
                    let items = returnVo.result as! Array<Dictionary<String, Any>>
                    
                    if( items.count == 0 ){
                        
                        if( search.count >= 40 ){
                            // serach text perfect address address cell 1ea
                            //TODO: - check validate Address
                            let addressPlanet = Planet()
                            addressPlanet.address = self.search
                            addressPlanet.coinType = self.planet?.coinType
                            results.append(addressPlanet)
                        }
                        
                    }else{
                        // DataSource update
                        items.forEach { (item) in
                            //except self item
                            if let itemName = item["name"] as? String, let selfName = self.planet?.name {
                                if itemName != selfName {
                                    results.append(Planet(JSON: item)!)
                                }
                            }
                        }
                    }
                    
                    adapter?.dataSetNotify(results)
                    updateUI()
                }
            }
        }
        
    }
}

extension TransferController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sendAction(segue: Keys.Segue.TRANSFER_TO_TRANSFER_AMOUNT,
                   userInfo: [Keys.UserInfo.toPlanet: adapter?.dataSource[indexPath.row] as Any,
                              Keys.UserInfo.planet: self.planet as Any,
                              Keys.UserInfo.erc20: self.erc20 as Any])
    }
}

extension TransferController: NavigationBarDelegate {
    func didTouchedBarItem(_ sender: ToolBarButton) {
        if sender == .LEFT {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            sendAction(segue: Keys.Segue.TRANSFER_TO_QRCAPTURE, userInfo: nil)
        }
    }
}


extension TransferController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.search = ""
        adapter?.dataSetNotify([])
        updateUI()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { //backspace
            search = String(search.dropLast())
        }
        else {
            search = textField.text! + string
        }
        
        if let planet = self.planet, let coinType = planet.coinType{
            Get(self).action(Route.URL("planet", "search", CoinType.of(coinType).name ),requestCode: 0, resultCode: 0, data:["q":search] )
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        magnifyingImgView.image = currentTheme.magnifyingPointImg
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        magnifyingImgView.image = currentTheme.magnifyingImg
    }
}

extension TransferController: QRCaptureDelegate {
    func didCapturedQRCode(_ address: String) {
        textField.text = address
        let addressPlanet = Planet()
        addressPlanet.address = address
        addressPlanet.coinType = self.planet?.coinType
        adapter?.dataSetNotify([addressPlanet])
        updateUI()
    }
}
