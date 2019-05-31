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
    func tableviewDidScroll(scrollView: UIScrollView)
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
    
    var isFirstScrollDelegated = true
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isFirstScrollDelegated == true {
            isFirstScrollDelegated = false
            return
        }
        
        delegate?.tableviewDidScroll(scrollView: scrollView)
    }
}

class PopupCountryCode: AbsSlideUpView {
    
    public var handler: ((DialCode?) -> Void)?
    
    @IBOutlet var containerView: UIView!

    let tableController = CountryCodeTableController()
    
    var dataSource: [DialCode]?
    
    let bottomGradientView = GradientView()
    let topGradientView = GradientView()
    
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
        
        tableController.view.frame = CGRect(x: 0, y: 15, width: containerView.bounds.width, height: containerView.bounds.height - (15*2))
        tableController.delegate = self
        containerView.addSubview(tableController.view)
/*
        let tableFrame = tableController.view.frame
        //top gradientView
        topGradientView.firstColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        topGradientView.secondColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        topGradientView.frame = CGRect(x: 0, y: tableFrame.minY, width: tableFrame.width, height: 15)
        containerView.addSubview(topGradientView)
        
        //bottom gradientView
        bottomGradientView.firstColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        bottomGradientView.secondColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        bottomGradientView.frame = CGRect(x: 0, y: tableFrame.maxY - 15, width: tableFrame.width, height: 15)
        containerView.addSubview(bottomGradientView)
  */
        setData()
    }
    
    public func setData() {
        tableController.datasource = dataSource
    }
}

extension PopupCountryCode: CountryCodeTableDelegate {
    func tableviewDidScroll(scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            //you reached end of the table
            bottomGradientView.isHidden = true
        }
        else {
            bottomGradientView.isHidden = false
        }
        
        if scrollView.contentOffset.y == 0 {
            //you reached top of the table
            topGradientView.isHidden = true
        }
        else {
            topGradientView.isHidden = false
        }
    }
    
    func didTouchedCode(dialCode: DialCode?) {
        self.handler?(dialCode)
    }
}
