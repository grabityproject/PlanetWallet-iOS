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

    let dummyContacts = [Contact(name: "song0", address: "0xanj123xax1241c231x2c1", type: .ETH),
                         Contact(name: "song1", address: "0x1421c46btdh2431x2c1", type: .ETH),
                         Contact(name: "song2", address: "0xcv346225c234c5cx2c1", type: .ETH),
                         Contact(name: "song3", address: "0x2v642325c23hiklll56", type: .ETH)]
    
    private let contactCellID = "contactCell"
    private let contactAddressCellID = "contractAddressCell"
    @IBOutlet var naviBar: NavigationBar!
    @IBOutlet var textField: PWTextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notFoundLb: PWLabel!
    @IBOutlet var paseClipboardBtn: UIButton!
    
    var state: State = .DEFAULT {
        didSet {
            updateUI()
        }
    }
    
    var contactList: [String] = []
    var contactListFiltered: [String] = []
    
    var search:String = ""
//    var isSearching = false {
//        didSet {
//            if isSearching {
////                state = .RESULTS
//                if contactListFiltered.isEmpty {
//                    state = .NOT_FOUND
//                }
//                else {
//                    state = .RESULTS
//                }
//            }
//            else {
//                state = .DEFAULT
//            }
//        }
//    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: contactCellID)
        tableView.register(ContactAddrCell.self, forCellReuseIdentifier: contactAddressCellID)
        naviBar.delegate = self
    }
    
    //MARK: - IBAction
    @IBAction func didTouchedPasteClipboard(_ sender: UIButton) {
        if let copiedStr = Utils.shared.getClipboard() {
            textField.text = copiedStr
            tableView.reloadData()
        }
    }
    
    //MARK: - Private
    private func updateUI() {
        switch state {
        case .DEFAULT:
            self.tableView.isHidden = true
            self.notFoundLb.isHidden = true
            if let _ = Utils.shared.getClipboard() {
                self.paseClipboardBtn.isHidden = false
            }
            else {
                self.paseClipboardBtn.isHidden = true
            }
        case .NOT_FOUND:
            self.tableView.isHidden = true
            self.notFoundLb.isHidden = false
            self.paseClipboardBtn.isHidden = true
        case .RESULTS:
            self.tableView.isHidden = false
            self.notFoundLb.isHidden = true
            self.paseClipboardBtn.isHidden = true
        }
    }
    
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
     
        if let dict = dictionary{
            if let returnVo = ReturnVO(JSON: dict){
                if( returnVo.success! ){
                    let items = returnVo.result as! Array<Dictionary<String, Any?>>
                    
                    if( items.count == 0 ){
                        
                        // serach text perfect address address cell 1ea
                        
                        // no result items
                        
                        
                    }else{
                        // DataSource update
                    }
                    
                    items.forEach { (item) in
                        let planet = Planet(JSON: item)
                        print(planet?.toJSON())
                    }
                }
            }
        }
        
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

extension TransferController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: currentTheme)
        if let addressCell = cell as? ContactAddrCell {
            addressCell.addressLb.setColoredAddress()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactCellID) as! ContactCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: contactAddressCellID, for: indexPath) as! ContactAddrCell
        cell.contact = dummyContacts[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendAction(segue: Keys.Segue.TRANSFER_TO_TRANSFER_AMOUNT, userInfo: nil)
    }
    
}

extension TransferController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.search = ""
//        isSearching = false
        tableView.reloadData()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.isSearching = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { //backspace
            search = String(search.dropLast())
        }
        else {
            search = textField.text! + string
        }
        
        Get(self).action(Route.URL("planet", "search", CoinType.ETH.name ),requestCode: 0, resultCode: 0, data:["q":search] )
        
        return true
    }
    
}

