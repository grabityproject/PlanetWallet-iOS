//
//  Utils.swift
//  PlanetWallet
//
//  Created by grabity on 01/05/2019.
//  Copyright © 2019 grabity. All rights reserved.
//

import Foundation
import UIKit


struct Utils {
    
    static let shared = Utils()
    
    private init() { }
    
    //MARK: - System Version
    ///Usages : SYSTEM_VERSION_EQUAL_TO("7.0")
    func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedSame
    }
    
    ///Usages : SYSTEM_VERSION_GREATER_THAN("7.0")
    func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedDescending
    }
    
    ///Usages : SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("7.0")
    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedAscending
    }
    
    ///Usages : SYSTEM_VERSION_LESS_THAN("7.0")
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedAscending
    }
    
    ///Usages : SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO("7.0")
    func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedDescending
    }
    
    
    //MARK: - Valid
    func isValid(email: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func isValid(phone: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
    }
    
    
    //MARK: - Date
    func changeDateFormat(date: String, beforFormat: DateFormat, afterFormat: DateFormat) -> String? {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = beforFormat.rawValue
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = afterFormat.rawValue
        
        //2014-05-22T03:46:25Z
        if let beforeDate = dateFormatterGet.date(from: date) {//2016-02-29 12:24:26
            return dateFormatterPrint.string(from: beforeDate)
        } else {
            print("There was an error decoding the string")
            return nil
        }
    }
    
    func changeDateFormat(date: Date, afterFormat: DateFormat) -> String? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = afterFormat.rawValue
        
        return dateFormatterPrint.string(from: date)
    }
    
    func getDateFromString(_ date: String, format: DateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.date(from: date)
    }
    
    func getStringFromDate(_ date: Date, format: DateFormat) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }
    
    func getTimeInterval(date: String, format: DateFormat) -> TimeInterval? {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.date(from: date)?.timeIntervalSince1970
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormat.BASIC.rawValue
        
        return formatter.string(from: Date())
    }
    
    //MARK: - Font
    func planetFont(style: FontStyle, size: CGFloat) -> UIFont? {
        
        return UIFont(name: style.rawValue, size: size)
    }
    
    //MARK: - UserDefaults
    func setDefaults(for key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getDefaults<T>(for key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
    
    //MARK: - StatusBar
    func statusBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
}

extension Utils {
    enum FontStyle: String {
        case BOLD = "WorkSans-Bold"
        case SEMIBOLD = "WorkSans-SemiBold"
        case MEDIUM = "WorkSans-Medium"
        case REGULAR = "WorkSans-Regular"
    }
}

extension Utils {
    /*
     Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
     09/12/2018                        --> MM/dd/yyyy
     09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
     Sep 12, 2:11 PM                   --> MMM d, h:mm a
     September 2018                    --> MMMM yyyy
     Sep 02, 2018                      --> MMM dd, yyyy
     Sep 2, 2018                       --> MMM d, yyyy
     Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
     2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
     12.09.18                          --> dd.MM.yy
     10:41:02.112                      --> HH:mm:ss.SSS
     Sep 02, 14:11                     --> MMM dd,HH:mm
     */
    enum DateFormat: String {
        ///2018-09-12 14:11:54
        case BASIC = "yyyy-MM-dd HH:mm:ss"
        ///2018-09-12T14:11:54+0000
        case BASIC_TZ = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        ///Sep 02, 2018
        case MMMddyyyy = "MMM dd,yyyy"
        ///Sep 02, 14:11
        case MMMddHHmm = "MMM dd,HH:mm"
    }
}
