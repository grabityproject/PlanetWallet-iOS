//
//  Post.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//
import Foundation
import Alamofire

class Post {
    var delegate :NetworkDelegate?
    
    init(_ delegate:NetworkDelegate? ) {
        self.delegate = delegate
    }
    
    func action(_ url:String, requestCode:Int, resultCode:Int, data:Dictionary<String,Any>? ) {
        
        guard let requestUrl = URL(string: url) else { return }
        
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data",
            "locale":LOCALE_CODE
        ]
        
        Alamofire.upload(
            multipartFormData: {
                (multipartFormData) in
                
                for (key, value) in data ?? [:]{
                    if value is Data {
                        multipartFormData.append(value as! Data, withName: key, fileName: key, mimeType: "*/*")
                    }else{
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
                
        },
            usingThreshold: UInt64.init(),
            to: requestUrl,
            method: .post,
            headers: headers) {
                (result) in
                switch result{
                case .success(let upload, _, _):

                    upload.response(completionHandler: { (dataResponse) in
                        
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
                        
                    })
                    
                case .failure(let error):
                    // Error Delegate
                    self.delegate?.onReceive(false, requestCode: requestCode, resultCode: resultCode, statusCode:0, result: error.localizedDescription, dictionary:nil)

                }
        }
    }
    
    
    func action(_ url:String ) {
        self.action(url, requestCode: 0, resultCode: 0, data: nil)
    }
    
    func actionMultipart(_ url:String, requestCode:Int, resultCode:Int, data:Data?) {
        guard let requestUrl = URL(string: url) else { return }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in

            if let data = data {
                multipartFormData.append(data, withName: "song", fileName: "song.png", mimeType: "*/*")
                multipartFormData.append(data, withName: "song")
            }
            
        }, usingThreshold: UInt64.init(), to: requestUrl, method: .post, headers: nil) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    print(response)
                    if let err = response.error{
                        print(err)
                        return
                    }
                    
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                
            }
        }
        
    }
}
