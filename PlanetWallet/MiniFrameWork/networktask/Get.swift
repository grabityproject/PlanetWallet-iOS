//
//  Get.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//
import Foundation
import Alamofire

class Get {
   
    var delegate :NetworkDelegate?
    
    init(_ delegate:NetworkDelegate? ) {
        self.delegate = delegate
    }
    
    func response(_ url:String, requestCode:Int, resultCode:Int, data:Dictionary<String,Any>?, extraHeaders:Dictionary<String,String> = [String:String]() )->[String:Any]{
        
        var result = [String:Any]()
        result["success"] = false;
        result["requestCode"] = requestCode;
        result["resultCode"] = resultCode;
      
        guard let requestUrl = URL(string: url) else { return result }
        
        var headers: HTTPHeaders = [
            "locale":LOCALE_CODE
        ]
        
        if extraHeaders.count > 0{
            extraHeaders.keys.forEach { (key) in
                headers[key] = extraHeaders[key]
            }
        }
        
        let dataResponse = Alamofire.request(requestUrl, method: .get, parameters: data, encoding: URLEncoding.default, headers: headers).responseData()
        
        if let response = dataResponse.response{
            if let resultData = dataResponse.data{
                do {
                    
                    if let resultJSON = try JSONSerialization.jsonObject(with: resultData, options: []) as? Dictionary<String, Any> {
                        
                        result["success"] = true;
                        result["statusCode"] = response.statusCode;
                        result["result"] = resultJSON["result"];
                        result["dictionary"] = resultJSON
                        
                    }
                }
                catch {
                    print("Failed to parsing json object")
                    
                    result["success"] = true;
                    result["statusCode"] = response.statusCode;
                    result["result"] = String(data: resultData, encoding: .utf8);
                    result["dictionary"] = [String:Any]()
                    
                }
            
            }
            
        }else{
            
            result["statusCode"] = 0;
            result["result"] = dataResponse.error?.localizedDescription;
            
        }
        
        return result
    }
    
    func action(_ url:String, requestCode:Int, resultCode:Int, data:Dictionary<String,Any>?, extraHeaders:Dictionary<String,String> = [String:String]() ) {
        
        guard let requestUrl = URL(string: url) else { return }
        
        var headers: HTTPHeaders = [
            "locale":LOCALE_CODE
        ]
        
        if extraHeaders.count > 0{
            extraHeaders.keys.forEach { (key) in
                headers[key] = extraHeaders[key]
            }
        }

        Alamofire.request(requestUrl, method: .get, parameters: data, encoding: URLEncoding.default, headers: headers).response { (dataResponse) in
            
            if let response = dataResponse.response{
                if let resultData = dataResponse.data{
                    do {
                        
                        if let resultJSON = try JSONSerialization.jsonObject(with: resultData, options: []) as? Dictionary<String, Any> {
                            
                            self.delegate?.onReceive(true,
                                                     requestCode: requestCode,
                                                     resultCode: resultCode,
                                                     statusCode: response.statusCode,
                                                     result: resultJSON["result"],
                                                     dictionary: resultJSON)
                        }
                    }
                    catch {
                        print("Failed to parsing json object")
                        self.delegate?.onReceive(true,
                                                 requestCode: requestCode,
                                                 resultCode: resultCode,
                                                 statusCode: response.statusCode,
                                                 result:String(data: resultData, encoding: .utf8),
                                                 dictionary: nil)
                    }
                }else{
                    self.delegate?.onReceive(false,
                                             requestCode: requestCode,
                                             resultCode: resultCode,
                                             statusCode: response.statusCode,
                                             result:nil,
                                             dictionary: nil)
                }
                
            }else{

                self.delegate?.onReceive(false,
                                         requestCode: requestCode,
                                         resultCode: resultCode,
                                         statusCode:0,
                                         result: dataResponse.error?.localizedDescription,
                                         dictionary:nil)
            }
            
        }
    }
    
    
    func action(_ url:String ) {
        self.action(url, requestCode: 0, resultCode: 0, data: nil)
    }
}
