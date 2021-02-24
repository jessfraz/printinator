//
//  OAuthCredentials.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

import Foundation

struct OAuthCredentials {
    let formlabsClientID, formlabsClientSecret: String
}

// Read our oauth credentials from the plist.
func getOAuthCredentials() -> OAuthCredentials? {
    guard let path = Bundle.main.path(forResource: "OAuthCredentials", ofType: "plist") else {return nil}
    let url = URL(fileURLWithPath: path)
    let data = try! Data(contentsOf: url)
    
    guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String:String] else {return nil}
    
    return OAuthCredentials(
        formlabsClientID: plist["env.FORMLABS_CLIENT_ID"] ?? "",
        formlabsClientSecret: plist["env.FORMLABS_CLIENT_SECRET"] ?? ""
    )
}
