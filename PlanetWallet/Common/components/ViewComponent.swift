//
//  TestMapper.swift
//  PlanetWallet
//
//  Created by 박상은 on 19/08/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit

class ViewComponent: UIView {
    
    var viewList:[String:UIView] = [String:UIView]()
    var controller:PlanetWalletViewController?;
    
    func viewMapping(){
        
    }
    
    func controller(_ controller:PlanetWalletViewController ) {
        self.controller = controller
    }
    
    func findViewById(_ objectId:String )->UIView?{
        if let controller = controller{
            self.findAllViews( view:controller.view);
        }
        return viewList[objectId]
    }
    
    private func findAllViews(view:UIView){
        if let identity = view.restorationIdentifier{
            viewList[identity] = view;
        }
        if view.subviews.count > 0{
            view.subviews.forEach { (cv) in
                findAllViews(view: cv);
            }
        }
    }
    
}
