//
//  NetworkDelegate.swift
//  PlanetWallet
//
//  Created by grabity on 29/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//


protocol NetworkDelegate {
    func onReceive(_ success:Bool, requestCode:Int, resultCode:Int, statusCode:Int, result:Any?, dictionary:Dictionary<String, Any>? )
}
