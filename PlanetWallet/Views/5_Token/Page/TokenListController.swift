//
//  TokenListView.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

class TokenListController: PlanetWalletViewController {
    
    private var planet:Planet = Planet()
    
    private var tokenList: [MainItem] = [MainItem]()
    private var tokenAdapter: TokenAdapter?
    
    @IBOutlet var textFieldContainer: PWView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var notFoundLb: UILabel!
    @IBOutlet var magnifyingImgView: PWImageView!
    
    var search:String=""
    var isSearching = false {
        didSet {
            if isSearching {
                notFoundLb.isHidden = !(tokenAdapter?.dataSource.isEmpty)!
                tableView.isHidden = tokenList.isEmpty
            }
            else {
                notFoundLb.isHidden = true
                tableView.isHidden = false
            }
        }
    }
    
    //MARK: - Init
    override func viewInit() {
        super.viewInit()
        //set textfield
        if let placeHolderFont = Utils.shared.planetFont(style: .REGULAR, size: 14) {
            textField.attributedPlaceholder = NSAttributedString(string: "token_list_search_title".localized,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText,
                                                                              NSAttributedString.Key.font: placeHolderFont])
        }
        textField.delegate = self
    }
    
    override func setData() {
        super.setData()
        
        guard let userInfo = self.userInfo,
            let planet = userInfo[Keys.UserInfo.planet] as? Planet
            else { navigationController?.popViewController(animated: false);  return  }
        
        self.planet = planet
        
        tokenAdapter = TokenAdapter(tableView, tokenList)
        tokenAdapter?.delegates.append(self)
        
        Get(self).action(Route.URL("token","ERC20"), requestCode: 0, resultCode: 0, data: nil)
    }
    
    override func onUpdateTheme(theme: Theme) {
        super.onUpdateTheme(theme: theme)
        textField.attributedPlaceholder = NSAttributedString(string: "token_list_search_title".localized,
                                                             attributes: [NSAttributedString.Key.foregroundColor: currentTheme.detailText])
    }
    
    
    //MARK: - Network
    override func onReceive(_ success: Bool, requestCode: Int, resultCode: Int, statusCode: Int, result: Any?, dictionary: Dictionary<String, Any>?) {
        if let dict = dictionary, let keyId = planet.keyId, let returnVo = ReturnVO(JSON: dict), let isSuccess = returnVo.success {
            if( isSuccess ){
                tokenList.removeAll()
                
                let dbItems = MainItemStore.shared.list(keyId, true)
                var dbMaps = [String:MainItem]()
                
                dbItems.forEach { (token) in
                    
                    if let contract = token.contract {
                        dbMaps[contract] = token
                    }
                }
                
                let items = returnVo.result as! [[String:Any]]
                items.forEach { (item) in
                    let token = MainItem(JSON: item)!
                    
                    token.hide = "Y"
                    if let contract = token.contract, let dbToken = dbMaps[contract] {
                        token.hide = dbToken.hide
                    }
                    
                    tokenList.append(token)
                }
                
                tokenAdapter?.dataSetNotify(tokenList)
            }
            else {
                if let errDict = returnVo.result as? [String: Any],
                    let errorMsg = errDict["errorMsg"] as? String
                {
                    Toast(text: errorMsg).show()
                }
            }
        }
    }
}

extension TokenListController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // DataBase Input
        
        if let item = tokenAdapter?.dataSource[indexPath.row], let keyId = planet.keyId {
       
            let token = MainItem()
            token._id = item._id
            token.keyId = keyId
            token.contract = item.contract
            token.symbol = item.symbol
            token.decimals = item.decimals
            token.name = item.name
            token.img_path = item.img_path
            token.balance = item.balance
            token.coinType = CoinType.ERC20.coinType
            token.hide = item.hide
            
            MainItemStore.shared.tokenSave(token)
        }
      
    }
}


extension TokenListController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
 
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.search = ""
        isSearching = false
        tokenAdapter?.dataSetNotify(tokenList)
        textField.resignFirstResponder()
        return true
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        magnifyingImgView.image = currentTheme.magnifyingPointImg
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isSearching = false
        magnifyingImgView.image = currentTheme.magnifyingImg
    }
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { //backspace
            search = String(search.dropLast())
            if search.isEmpty {
                isSearching = false
                tokenAdapter?.dataSetNotify(tokenList)
                return true
            }
        }
        else {
            search = textField.text! + string
        }
 
        tokenAdapter?.dataSetNotify(tokenList.filter({
            guard let name = $0.name?.uppercased(), let symbol = $0.symbol?.uppercased() else { return false }
            
            return name.contains(search.uppercased()) || symbol.contains(search.uppercased())
        }))
        
        isSearching = true
        
        return true
    }
}
