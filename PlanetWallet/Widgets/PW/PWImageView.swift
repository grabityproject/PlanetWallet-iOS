//
//  PWImageView.swift
//  PlanetViewTest
//
//  Created by 박상은 on 09/05/2019.
//  Copyright © 2019 박상은. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

@IBDesignable class PWImageView: UIImageView, Themable {
    
    var imageURL: URL?
    
//    override var image: UIImage? {
//        didSet {
//            self.defaultImage = image
//        }
//    }
    
    var defaultImage: UIImage?
    private var defaultBackgroundColor: UIColor?
    private var defaultBorderColor: UIColor?
    
    @IBInspectable var themeImage: UIImage?{
        didSet{
            self.defaultImage = self.image
        }
    }
    
    @IBInspectable var themeBackgroundColor: UIColor?{
        didSet{
            self.defaultBackgroundColor = self.backgroundColor
        }
    }
    
    @IBInspectable var themeBorderColor: UIColor?{
        didSet{
            self.defaultBorderColor = borderColor
        }
    }
    
    func setTheme(_ theme: Theme) {
        if( theme == Theme.LIGHT ){
            if( defaultBackgroundColor == nil ){
                defaultBackgroundColor = self.backgroundColor;
            }
            if( defaultBorderColor == nil ){
                defaultBorderColor = borderColor;
            }
            if( defaultImage == nil ){
                defaultImage = self.image
            }
            
            self.backgroundColor = self.themeBackgroundColor
            self.layer.borderColor = themeBorderColor?.cgColor
            if self.themeImage == nil {
                self.image = self.defaultImage
            }
            else {
                self.image = self.themeImage
            }
        }else{
            if( self.defaultBackgroundColor != nil ){
                self.backgroundColor = self.defaultBackgroundColor
            }
            if( self.defaultBorderColor != nil ){
                self.layer.borderColor = defaultBorderColor?.cgColor
            }
            if( self.defaultImage != nil ){
                self.image = defaultImage
            }
        }
    }
    
    
    //MARK: - Network
    func loadImageWithPath(_ path: String) {
        
        guard let url = URL(string: path) else { return }
        self.loadImageWithUrl(url)
    }
    
    func loadImageWithUrl(_ url: URL) {
        imageURL = url
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let unwrappedData = data, let imageToCache = UIImage(data: unwrappedData) {
                    
                    if self.imageURL == url {
                        
                        self.image = imageToCache
                    }
                    
                    imageCache.setObject(imageToCache, forKey: url as AnyObject)
                }
            })
        }).resume()
    }
}
