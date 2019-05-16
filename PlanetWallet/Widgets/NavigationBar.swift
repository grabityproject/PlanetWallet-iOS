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
    
    public var delegate : NavigationBarDelegate?
    
    var backgroundView : UIView = UIView()
    var leftImageView : UIImageView = UIImageView()
    var rightImageView : UIImageView = UIImageView()
    var labelTitle: UILabel = UILabel()
    var bottomBar : UIView = UIView()

    @IBInspectable var title : String!{
        get{
            return labelTitle.text
        }
        set{
            labelTitle.text = newValue
        }
    }
    
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
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: UIScreen.main.bounds.width, height:UIApplication.shared.statusBarFrame.height + 68)
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height);
        labelTitle.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.frame.width, height: self.frame.height - UIApplication.shared.statusBarFrame.height);
        leftImageView.frame = CGRect(x: 11, y: (self.frame.height - UIApplication.shared.statusBarFrame.height - 40)/2.0 + UIApplication.shared.statusBarFrame.height, width: 40, height: 40);
        rightImageView.frame = CGRect(x: self.frame.width - 11 - 40, y: (self.frame.height - UIApplication.shared.statusBarFrame.height - 40)/2.0 + UIApplication.shared.statusBarFrame.height, width: 40, height: 40);
        bottomBar.frame = CGRect(x: 0, y: self.frame.height-1, width: self.frame.width, height: 1);
        
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold);
        
        leftImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onLeftButtonClick)))
        rightImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRightButtonClick)))
        
        leftImageView.isUserInteractionEnabled = true;
        rightImageView.isUserInteractionEnabled = true;
        
        
        
        addSubview(backgroundView)
        addSubview(labelTitle)
        addSubview(leftImageView)
        addSubview(rightImageView)
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
        if( delegate != nil ){
            delegate?.didTouchedBarItem(.LEFT)
        }
    }
    
    @objc func onRightButtonClick(_ sender:Any?){
        if( delegate != nil ){
            delegate?.didTouchedBarItem(.RIGHT)
        }
    }
    
}
