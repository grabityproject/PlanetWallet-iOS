//
//  TokenListView.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

extension TokenListController {
    class Token {
        let name: String
        let icon: UIImage
        
        var isRegistered: Bool = false
        
        init(name: String, icon: UIImage, isRegistered: Bool = false) {
            self.name = name
            self.icon = icon
            self.isRegistered = isRegistered
        }
    }
}

class TokenListController: PlanetWalletViewController {
    
    let cellID = "tokencell"
    
    var tokenList: [Token] = [Token]()
    
    var tokenListFiltered: [Token] = [Token]()
    var search:String=""
    var isSearching = false {
        didSet {
            if isSearching {
                if tokenListFiltered.isEmpty {
                    tableView.isHidden = true
                }
                else {
                    tableView.isHidden = false
                }
            }
            else {
                tableView.isHidden = false
                tokenListFiltered.removeAll()
            }
        }
    }
    
    @IBOutlet var textFieldContainer: UIView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        
        //set textfield
        if let placeHolderFont = Utils.shared.planetFont(style: .REGULAR, size: 14) {
            textField.attributedPlaceholder = NSAttributedString(string: "Search",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText,
                                                                              NSAttributedString.Key.font: placeHolderFont])
        }
        textField.delegate = self
        
        //set tableview
        tableView.register(TokenCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func setData() {
        super.setData()
        
        tokenList.append(Token(name: "ETH", icon: UIImage(named: "tokenIconETH")!, isRegistered: true))
        tokenList.append(Token(name: "GBT", icon: UIImage(named: "tokenIconGBT")!, isRegistered: true))
        tokenList.append(Token(name: "OMG", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG2", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG3", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG4", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG5", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG6", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG7", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG8", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG10", icon: UIImage(named: "tokenIconOMG")!, isRegistered: true))
        tokenList.append(Token(name: "OMG11", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG12", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG13", icon: UIImage(named: "tokenIconOMG")!, isRegistered: true))
        tokenList.append(Token(name: "OMG14", icon: UIImage(named: "tokenIconOMG")!))
        tokenList.append(Token(name: "OMG15", icon: UIImage(named: "tokenIconOMG")!))
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        textField.attributedPlaceholder = NSAttributedString(string: "Search",
                                                             attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText])
        
    }
}

extension TokenListController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isSearching = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty
        {
            search = String(search.dropLast())
            isSearching = false
            self.tableView.reloadData()
            return true
        }
        
        search = textField.text! + string
        self.tokenListFiltered = tokenList.filter({ return $0.name.uppercased().contains(search.uppercased()) })
        isSearching = true
        

        self.tableView.reloadData()
        return true
    }
}

extension TokenListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! TokenCell
        
        if isSearching == false {
            cell.tokenInfo = tokenList[indexPath.row]
            if tokenList[indexPath.row].isRegistered {
                cell.checkedImgView.isHidden = false
            }
            else {
                cell.checkedImgView.isHidden = true
            }
            
        }
        else {
            cell.tokenInfo = tokenListFiltered[indexPath.row]
            if tokenListFiltered[indexPath.row].isRegistered {
                cell.checkedImgView.isHidden = false
            }
            else {
                cell.checkedImgView.isHidden = true
            }
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == false {
            return tokenList.count
        }
        else {
            return tokenListFiltered.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension TokenListController: TokenCellDelegate {
    func didSelected(indexPath: IndexPath, isRegistered: Bool) {
        tokenList[indexPath.row].isRegistered = isRegistered
    }
    
}
