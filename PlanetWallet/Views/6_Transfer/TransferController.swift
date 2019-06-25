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
    var adapter : PlanetSearchAdapter?
    
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notFoundLb: PWLabel!
    @IBOutlet var paseClipboardBtn: UIButton!
    
    var search:String = ""
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        naviBar.delegate = self
    }
    
    override func setData() {
        
        if let userInfo = self.userInfo, let planet = userInfo["planet"] as? Planet{
            self.planet = planet
            
            adapter = PlanetSearchAdapter(tableView, []);
            adapter?.delegates.append(self)
            updateUI()
            
        }else{
            // TODO: 죽자
            print("No data")
        }
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedPasteClipboard(_ sender: UIButton) {
        if let copiedStr = Utils.shared.getClipboard() {
            textField.text = copiedStr
//            Get(self).action(Route.URL("planet", "search", CoinType.ETH.name ),requestCode: 0, resultCode: 0, data:["q":copiedStr] )
        }
    }
    
    //MARK: - Private
    private func updateUI() {
        
        if let a = adapter{
            if( a.dataSource.count == 0 && search.count == 0 ){
                
                self.tableView.isHidden = true
                self.notFoundLb.isHidden = true
                self.paseClipboardBtn.isHidden = Utils.shared.getClipboard() == nil
                
            }else if( a.dataSource.count == 0 && search.count != 0 ){
                
                self.tableView.isHidden = true
                self.notFoundLb.isHidden = false
                self.paseClipboardBtn.isHidden = true
                
            }else{
                
                self.tableView.isHidden = false
                self.notFoundLb.isHidden = true
                self.paseClipboardBtn.isHidden = true
                
            }
        }
    }
    
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
                            let planet = Planet()
                            planet.address = self.search
                            results.append(planet)
                            
                        }
                        
                    }else{
                        // DataSource update
                        items.forEach { (item) in
                            results.append(Planet(JSON: item)!)
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
        sendAction(segue: Keys.Segue.TRANSFER_TO_TRANSFER_AMOUNT, userInfo: ["Planet":adapter?.dataSource[indexPath.row]])
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
    
}

