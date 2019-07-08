//
//  Get.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//
import Foundation
import Alamofire

class Patch {
   
    var delegate :NetworkDelegate?
    
    init(_ delegate:NetworkDelegate? ) {
        self.delegate = delegate
    }
    
    func action(_ url:String, requestCode:Int, resultCode:Int, data:Dictionary<String,Any>? ) {
        
        guard let requestUrl = URL(string: url) else { return }
        Alamofire.request(requestUrl, method: .patch, parameters: data, encoding: URLEncoding.default, headers: ["locale":LOCALE_CODE]).response { (dataResponse) in
            
            if let response = dataResponse.response{
                if let resultData = dataResponse.data{
                    do {
                        let resultJSON = try JSONSerialization.jsonObject(with: resultData, options: [])
                        self.delegate?.onReceive(true, requestCode: requestCode, resultCode: resultCode, statusCode: response.statusCode, result: resultJSON, dictionary: resultJSON as? Dictionary<String, Any>)
                    }
                    catch {
                        self.delegate?.onReceive(true, requestCode: requestCode, resultCode: resultCode, statusCode: response.statusCode, result:String(data: resultData, encoding: .utf8), dictionary: nil)
                    }
                }else{
                    self.delegate?.onReceive(false, requestCode: requestCode, resultCode: resultCode, statusCode: response.statusCode, result:nil, dictionary: nil)
                }
                
            }else{

                self.delegate?.onReceive(false, requestCode: requestCode, resultCode: resultCode, statusCode:0, result: dataResponse.error?.localizedDescription, dictionary:nil)
            }
            
        }
    }
    
    
    func action(_ url:String ) {
        self.action(url, requestCode: 0, resultCode: 0, data: nil)
    }
}
