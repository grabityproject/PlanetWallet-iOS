//
//  ToolBar.swift
//  PlanetViewTest
//
//  Created by 박상은 on 14/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

public enum ToolBarButton {
    case LEFT, RIGHT
}

public protocol NavigationBarDelegate {
    func didTouchedBarItem(_ sender:ToolBarButton )
}

@IBDesignable class NavigationBar: UIView, Themable {
    @IBInspectable var theme : Bool = false;
    @IBInspectable var defaultTitleColor : UIColor!
    @IBInspectable var themeTitleColor : UIColor!
    @IBInspectable var defaultBackgroundColor : UIColor!
    @IBInspectable var themeBackgroundColor : UIColor!
    @IBInspectable var defaultLeftImage : UIImage!
    @IBInspectable var themeLeftImage : UIImage!
    @IBInspectable var defaultRightImage : UIImage!
    @IBInspectable var themeRightImage : UIImage!
    @IBInspectable var defaultBarColor : UIColor!
    @IBInspectable var themeBarColor : UIColor!
    
    public var delegate : NavigationBarDelegate?
    
    static var height: CGFloat {
        return Utils.shared.statusBarHeight() + 68
    }
    
    var title : String! {
        get { return labelTitle.text }
        set { labelTitle.text = newValue }
    }
    
    let itemSize: CGSize = CGSize(width: 40, height: 40)
    let itemTouchSize: CGSize = CGSize(width: 68, height: 68)
    
    var backgroundView = UIView()
    var leftImageView = UIImageView()
    var leftItemBtn = UIButton()
    var rightImageView = UIImageView()
    var rightItemBtn = UIButton()
    var labelTitle = UILabel()
    var bottomBar = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewInit()
    }
    
    override func prepareForInterfaceBuilder() {
        viewInit()
        setTheme(theme ? Theme.LIGHT : Theme.DARK)
    }
    
    private func viewInit() {
        
        let statusBarHeight = Utils.shared.statusBarHeight()
        
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: UIScreen.main.bounds.width,
                            height:statusBarHeight + 68)
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height);
        
        leftImageView.frame = CGRect(x: 11,
                                     y: (self.frame.height - statusBarHeight - itemSize.height)/2.0 + statusBarHeight,
                                     width: itemSize.width,
                                     height: itemSize.height)
        leftItemBtn.frame = CGRect(x: 0,
                                   y: (self.frame.height - statusBarHeight - itemTouchSize.height)/2.0 + statusBarHeight,
                                   width: itemTouchSize.width,
                                   height: itemTouchSize.height)
        
        rightImageView.frame = CGRect(x: self.frame.width - 11 - 40,
                                      y: (self.frame.height - statusBarHeight - itemSize.height)/2.0 + statusBarHeight,
                                      width: itemSize.width,
                                      height: itemSize.height)
        rightItemBtn.frame = CGRect(x: self.frame.width - itemTouchSize.width,
                                    y: (self.frame.height - statusBarHeight - itemTouchSize.height)/2.0 + statusBarHeight,
                                    width: itemTouchSize.width,
                                    height: itemTouchSize.height)
        
        bottomBar.frame = CGRect(x: 0,
                                 y: self.frame.height-1,
                                 width: self.frame.width,
                                 height: 1);
        
        labelTitle.frame = CGRect(x: 0, y: statusBarHeight, width: self.frame.width, height: self.frame.height - statusBarHeight);
        
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold);

        leftItemBtn.setTitle("", for: .normal)
        rightItemBtn.setTitle("", for: .normal)
        leftItemBtn.addTarget(self, action: #selector(onLeftButtonClick(_:)), for: .touchUpInside)
        rightItemBtn.addTarget(self, action: #selector(onRightButtonClick(_:)), for: .touchUpInside)
        
        leftImageView.isUserInteractionEnabled = true;
        rightImageView.isUserInteractionEnabled = true;
        
        addSubview(backgroundView)
        addSubview(labelTitle)
        addSubview(leftImageView)
        addSubview(leftItemBtn)
        addSubview(rightImageView)
        addSubview(rightItemBtn)
        addSubview(bottomBar)
    }
    
    func setTheme(_ theme: Theme) {
        if( theme == .LIGHT){
            backgroundView.backgroundColor = themeBackgroundColor
            labelTitle.textColor = themeTitleColor
            leftImageView.image = themeLeftImage
            rightImageView.image = themeRightImage
            bottomBar.backgroundColor = themeBarColor
        }else{
            backgroundView.backgroundColor = defaultBackgroundColor
            labelTitle.textColor = defaultTitleColor
            leftImageView.image = defaultLeftImage
            rightImageView.image = defaultRightImage
            bottomBar.backgroundColor = defaultBarColor
        }
    }
    
    @objc func onLeftButtonClick(_ sender:Any?){
        if( delegate != nil && leftImageView.image != nil){
            delegate?.didTouchedBarItem(.LEFT)
        }
    }
    
    @objc func onRightButtonClick(_ sender:Any?){
        if( delegate != nil && rightImageView.image != nil ){
            delegate?.didTouchedBarItem(.RIGHT)
        }
    }
    
}
