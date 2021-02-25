//
//  Makerbot.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

import Foundation
import SwiftJSONRPC
import PromiseKit

class Makerbot: ObservableObject {
    // Client ID/secret, for LAN access.
    let clientID = "MakerWare"
    let clientSecret = "secret"
    
    var printerIPs: [String] = UserDefaults.standard.makerbotPrinterIPs {
        didSet {
            // Update UserDefaults whenever our local value for printerIPs is updated.
            UserDefaults.standard.makerbotPrinterIPs = printerIPs
        }
    }
    
    init() {
        print(printerIPs)
        
        // For each printer IP we want to create a client.
        for printerIP in printerIPs {
            let url = URL(string: "http://" + printerIP + ":9999")!
            let client = RPCClient(url: url)
            
            // Let's authenticate the client.
            //client.invoke("handshake")
        }
    }
}
