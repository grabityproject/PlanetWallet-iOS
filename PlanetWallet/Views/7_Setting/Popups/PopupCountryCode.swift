//
//  PopupCountryCode.swift
//  PlanetWallet
//
//  Created by grabity on 14/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import UIKit

protocol CountryCodeTableDelegate {
    func didTouchedCode(dialCode: DialCode?)
}

class CountryCodeTableController: UITableViewController {
    private let cellID = "countryCodeCell"
    
    public var datasource: [DialCode]?
    
    var delegate: CountryCodeTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableView.register(CountryCodeCell.self, forCellReuseIdentifier: cellID)
        self.tableView.rowHeight = 48.0
        
        switch ThemeManager.currentTheme() {
        case .DARK:     tableView.backgroundColor = UIColor.white
        case .LIGHT:    tableView.backgroundColor = UIColor(named: "borderDark")
        }
    }
    
    func findAllViews( view:UIView, theme:Theme ){
        
        if( view is Themable ){
            (view as! Themable).setTheme(theme)
        }
        
        if( view.subviews.count > 0 ){
            view.subviews.forEach { (v) in
                
                findAllViews(view: v, theme: theme)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CountryCodeCell
        cell.nameLb.text = datasource?[indexPath.row].name
        cell.codeLb.text = datasource?[indexPath.row].code
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = datasource {
            return list.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        findAllViews(view: cell, theme: ThemeManager.currentTheme())
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTouchedCode(dialCode: datasource?[indexPath.row])
    }
}

class PopupCountryCode: AbsSlideUpView, CountryCodeTableDelegate {
    
    public var handler: ((DialCode?) -> Void)?
    
    @IBOutlet var containerView: UIView!

    let tableController = CountryCodeTableController()
    
    var dataSource: [DialCode]?
    
    convenience init(dataSource: [DialCode]) {
        self.init()
        
        self.dataSource = dataSource
    }
    
    override func setXib() {
        super.setXib()
        
        Bundle.main.loadNibNamed("PopupCountryCode", owner: self, options: nil)
        contentView = containerView
        
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        containerView.addSubview(tableController.view)
        tableController.view.frame = containerView.bounds
        tableController.delegate = self
        setData()
    }
    
    public func setData() {
        tableController.datasource = dataSource
    }
    
    
    
    func didTouchedCode(dialCode: DialCode?) {
        handler?(dialCode)
    }
}
