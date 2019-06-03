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
    
    let darkBottomGradientView = GradientView()
    let darkTopGradientView = GradientView()
    
    let lightBottomGradientView = GradientView()
    let lightTopGradientView = GradientView()
    
    //MARK: - Init
    convenience init(dataSource: [DialCode]) {
        self.init()
        
        self.dataSource = dataSource
    }
    
    override func setXib() {
        super.setXib()
        
        Bundle.main.loadNibNamed("PopupCountryCode", owner: self, options: nil)
        
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        containerView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - (32*2), height: SCREEN_HEIGHT * 0.67)
        contentView = containerView
        
        tableController.view.frame = CGRect(x: 0, y: 15, width: containerView.bounds.width, height: containerView.bounds.height - (15*2))
        tableController.delegate = self
        containerView.addSubview(tableController.view)
        
        createGradientView()

        setData()
    }
    
    public func setData() {
        tableController.datasource = dataSource
    }
    
    //MARK: - Private
    private func createGradientView() {
        
        let tableFrame = tableController.view.frame
        
        //top gradientView
        lightTopGradientView.startColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        lightTopGradientView.endColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        lightTopGradientView.frame = CGRect(x: 0, y: tableFrame.minY, width: tableFrame.width, height: 15)
        containerView.addSubview(lightTopGradientView)
        
        //bottom gradientView
        lightBottomGradientView.startColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0)
        lightBottomGradientView.endColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        lightBottomGradientView.frame = CGRect(x: 0, y: tableFrame.maxY - 15, width: tableFrame.width, height: 15)
        containerView.addSubview(lightBottomGradientView)
        
        //top gradientView
        darkTopGradientView.startColor = UIColor(red: 30, green: 30, blue: 40, alpha: 1)
        darkTopGradientView.endColor = UIColor(red: 30, green: 30, blue: 40, alpha: 0)
        darkTopGradientView.frame = CGRect(x: 0, y: tableFrame.minY, width: tableFrame.width, height: 15)
        containerView.addSubview(darkTopGradientView)
        
        //bottom gradientView
        darkBottomGradientView.startColor = UIColor(red: 30, green: 30, blue: 40, alpha: 0)
        darkBottomGradientView.endColor = UIColor(red: 30, green: 30, blue: 40, alpha: 1)
        darkBottomGradientView.frame = CGRect(x: 0, y: tableFrame.maxY - 15, width: tableFrame.width, height: 15)
        containerView.addSubview(darkBottomGradientView)
        
        if ThemeManager.currentTheme() == .DARK {
            darkTopGradientView.isHidden = true
            darkBottomGradientView.isHidden = true
            
            lightTopGradientView.isHidden = false
            lightBottomGradientView.isHidden = false
        }
        else {
            darkTopGradientView.isHidden = false
            darkBottomGradientView.isHidden = false
            
            lightTopGradientView.isHidden = true
            lightBottomGradientView.isHidden = true
        }
    }
}

extension PopupCountryCode: CountryCodeTableDelegate {
    func tableviewDidScroll(scrollView: UIScrollView) {
        
        var bottomGradient: GradientView?
        var topGradient: GradientView?
        
        if ThemeManager.currentTheme() == .DARK {
            bottomGradient = lightBottomGradientView
            topGradient = lightTopGradientView
        }
        else {
            bottomGradient = darkBottomGradientView
            topGradient = darkTopGradientView
        }
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            //you reached end of the table
            bottomGradient?.isHidden = true
        }
        else {
            bottomGradient?.isHidden = false
        }
        
        if scrollView.contentOffset.y == 0 {
            //you reached top of the table
            topGradient?.isHidden = true
        }
        else {
            topGradient?.isHidden = false
        }
    }
    
    func didTouchedCode(dialCode: DialCode?) {
        self.handler?(dialCode)
    }
}
