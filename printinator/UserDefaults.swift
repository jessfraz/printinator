//
//  UserDefaults.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import Foundation

// Store data in UserDefaults.
// This allows us to more easily access it later.
extension UserDefaults {
    @objc dynamic var token: String {
        get { string(forKey: "token") ?? "" }
        set { setValue(newValue, forKey: "token") }
    }
    
    @objc dynamic var refreshToken: String {
        get { string(forKey: "refreshToken") ?? "" }
        set { setValue(newValue, forKey: "refreshToken") }
    }
    
    @objc dynamic var tokenExpirationDate: Date {
        get { (object(forKey: "tokenExpirationDate") as? Date) ?? Date() }
        set { setValue(newValue, forKey: "tokenExpirationDate") }
    }
    
    @objc dynamic var username: String {
        get { string(forKey: "username") ?? "" }
        set { setValue(newValue, forKey: "username") }
    }
    
    @objc dynamic var password: String {
        get { string(forKey: "password") ?? "" }
        set { setValue(newValue, forKey: "password") }
    }
    
    @objc dynamic var makerbotPrinterIPs: [String] {
        get { (object(forKey: "makerbotPrinterIPs") as? [String]) ?? [String]() }
        set { setValue(newValue, forKey: "makerbotPrinterIPs") }
    }
}
