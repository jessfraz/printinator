//
//  Makerbot.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

import Alamofire
import Combine
import Foundation
import NIO

class Makerbot: NSObject, ObservableObject, NetServiceBrowserDelegate {
    // Client ID/secret, for LAN access.
    let clientID = "MakerWare"
    let clientSecret = "secret"
    
    // Local network service browser.
    let browserAgent = BrowserAgent()
    var browser = NetServiceBrowser.init()
    
    var printerIPs: [String:String] = UserDefaults.standard.makerbotPrinterIPs {
        didSet {
            // Update UserDefaults whenever our local value for printerIPs is updated.
            UserDefaults.standard.makerbotPrinterIPs = printerIPs
        }
    }
    
    // Variables that publish items in the UI.
    @Published var printers: [MakerbotPrinter] = [MakerbotPrinter]()
    
    private var cancelablePrinterIPs: AnyCancellable?
    override init() {
        super.init()
        
        // Browse the network for printers.
        self.browseNetworkForPrinters()
        
        // Listen for changes to printerIPs, we need to do this
        // because the service discovery changes printerIPs.
        cancelablePrinterIPs = UserDefaults.standard.publisher(for: \.makerbotPrinterIPs)
            // Wait for a pause in the delivery of events from the upstream publisher.
            // Only receive elements when the we haven't found a new printer in 5 seconds.
            // This is in case we find a bunch on the network at one time.
            .debounce(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else { return }
                if newValue != self.printerIPs { // avoid cycling !!
                    self.printerIPs = newValue
                
                    // When the printers change, update our list of printers.
                    // Get the printers as a background thread.
                    DispatchQueue.global(qos: .background).async {
                        self.getPrinters()
                    }
                }
            })
        
        // Get the printers as a background thread.
        DispatchQueue.global(qos: .background).async {
            self.getPrinters()
            print(self.printers)
        }
    }
    
    
    func getPrinters() {
        var refreshedPrinters = [MakerbotPrinter]()
        
        // For each printer IP we want to create a client.
        for (printerIP, printerToken) in printerIPs {
            // Connect to the client.
            let (ip, port) = printerIP.getIPAndPort()
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let client = TCPClient(group: eventLoopGroup, config: TCPClient.Config(framing: .brute))
            // Try to connect.
            do {
                let _ = try client.connect(host: ip, port: port).wait()
                switch try client.call(method: "handshake", params: .none).wait() {
                    case .failure(let error):
                        print("handshake failed with \(error)")
                    case .success(let response):
                        var printer = MakerbotPrinter(response)!
                        
                        // Set the token for the printer so the views know we authenticated it.
                        printer.token = printerToken
                        printer.lastPingedAt = Date()
                        
                        // Add the printer to our array of printers.
                        refreshedPrinters.append(printer)
                        
                        if printerToken.isEmpty {
                            // Continue through the loop, since we aren't authenticated.
                            continue
                        }
                }
                
                // Send the authentication.
                switch try client.call(method: "authenticate", params: RPCObject(["access_token": printerToken])).wait() {
                    case .failure(let error):
                        print("authenticate failed with \(error)")
                        // Reset the token and try again.
                        self.printerIPs[printerIP] = ""
                    case .success(let response):
                        print("authenticated to", printerIP, response)
                }
                
                // Get system information.
                switch try client.call(method: "get_system_information", params: .none).wait() {
                    case .failure(let error):
                        print("get_system_information failed with \(error)")
                    case .success(let response):
                        print("response", response)
                }
                
                // Get queue status.
                switch try client.call(method: "get_queue_status", params: .none).wait() {
                    case .failure(let error):
                        print("get_queue_status failed with \(error)")
                    case .success(let response):
                        print("response", response)
                }
                
                // Get print history.
                switch try client.call(method: "get_print_history", params: .none).wait() {
                    case .failure(let error):
                        print("get_print_history failed with \(error)")
                    case .success(let response):
                        print("response", response)
                }
                
                // Get statistics.
                switch try client.call(method: "get_statistics", params: .none).wait() {
                    case .failure(let error):
                        print("get_statistics failed with \(error)")
                    case .success(let response):
                        print("response", response)
                }
                
                // Disconnect.
                try client.disconnect().wait()
            } catch {
                print("could not connect to printer", printerIP)
            }
        }
        
        DispatchQueue.main.async {
            self.printers = refreshedPrinters
        }
    }
    
    // Browse for any Makerbot printers on the network.
    func browseNetworkForPrinters() {
        // Call stop just in case we had already started.
        browser.stop()
        
        browser.delegate = self.browserAgent
        browser.searchForServices(ofType: "_makerbot-jsonrpc._tcp", inDomain: "local")
    }
    
    // Authenticate locally.
    func authenticateLocally(_ printerIP: String, name: String) -> String {
        let answerCode = getAuthAnswerCode(printerIP)
        if answerCode.isEmpty {
            print("answer code from makerbot auth was empty")
            return ""
        }
        
        let code = getAuthCode(printerIP, answerCode: answerCode)
        if code.isEmpty {
            print("code from makerbot auth was empty")
            return ""
        }
        
        let token = getAuthToken(printerIP, code: code)
        if token.isEmpty {
            print("access token from makerbot auth was empty")
            return ""
        }
        
        return token
    }
    
    func getAuthAnswerCode(_ printerIP: String) -> String {
        var completion = false
        var answerCode = ""
        
        // Send the request for the answerCode.
        AF.request(printerIP.getMakerbotAuthURL(), method: .get,
                   parameters: [
                    "response_type": "code",
                    "client_id": self.clientID,
                    "client_secret": self.clientSecret,
                   ])
            .validate(statusCode: [200])
            .validate(contentType: ["application/json"])
            .responseDecodable(of: MakerbotAuthResponse.self) { response in
                switch response.result {
                case .success:
                    if let data = response.value {
                        // Set the answer code.
                        answerCode = data.answerCode ?? ""
                        completion = true
                    } else {
                        print("getting the answer code from makerbot auth response failed")
                        completion = true
                    }
                case let .failure(error):
                    print("request for answer code from makerbot auth failed", error)
                    completion = true
                }
            }
        
        while !completion {
            // Wait for the request to return.
        }
        
        return answerCode
    }
    
    func getAuthCode(_ printerIP: String, answerCode: String) -> String {
        var code = ""
        
        // Poll for the answer from our request.
        var count = 0
        while (count < 60) {
            // Sleep for 2 seconds.
            sleep(UInt32(TimeInterval(2)))
        
            // Send back the answer code to get our answer.
            AF.request(printerIP.getMakerbotAuthURL(), method: .get,
                   parameters: [
                    "response_type": "answer",
                    "client_id": self.clientID,
                    "client_secret": self.clientSecret,
                    "answer_code": answerCode,
                   ])
            .validate(statusCode: [200])
            .validate(contentType: ["application/json"])
            .responseDecodable(of: MakerbotAuthResponse.self) { response in
                switch response.result {
                case .success:
                    if let data = response.value {
                        if data.answer != nil && data.code != nil {
                            // Break the loop if we got an answer and save the code.
                            code = data.code ?? ""
                            count = 60
                        }
                    } else {
                        print("getting the answer from makerbot auth response failed")
                    }
                case let .failure(error):
                    // Do nothing here since likely its just going to loop.
                    print("waiting for knob press", error)
                }
            }
            
            count += 1
        }
        
        return code
    }
    
    func getAuthToken(_ printerIP: String, code: String) -> String {
        var completion = false
        var token = ""
        
        // Send the request for the token.
        AF.request(printerIP.getMakerbotAuthURL(), method: .get,
                   parameters: [
                    "response_type": "token",
                    "client_id": self.clientID,
                    "client_secret": self.clientSecret,
                    "context": "jsonrpc",
                    "auth_code": code,
                   ])
            .validate(statusCode: [200])
            .validate(contentType: ["application/json"])
            .responseDecodable(of: MakerbotAuthResponse.self) { response in
                switch response.result {
                case .success:
                    if let data = response.value {
                        // Set the token.
                        token = data.accessToken ?? ""
                        completion = true
                    } else {
                        print("getting the access token from makerbot auth response failed")
                        completion = true
                    }
                case let .failure(error):
                    print("request for access token from makerbot auth failed", error)
                    completion = true
                }
            }
        
        while !completion {
            // Wait for the request to return.
        }
        
        return token
    }
}

class BrowserAgent : NSObject, NetServiceBrowserDelegate {
    var currentService: NetService?
    let serviceAgent = ServiceAgent()
    
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("network service discovery about to begin")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser,
                           didNotSearch errorDict: [String : NSNumber]){
        print("network service discovery error:", browser, errorDict)
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("network service discovery stopped")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("discovered a service", service.name, service.type, service.domain)
        
        // Resolve the service to get the IP.
        self.currentService = service
        service.delegate = self.serviceAgent
        service.resolve(withTimeout: 5)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser,
                      didFindDomain domainString: String,
                      moreComing: Bool){
        print("discovered a domain", domainString, moreComing)
    }
}

class ServiceAgent: NSObject, NetServiceDelegate {
    var printerIPs: [String:String] = UserDefaults.standard.makerbotPrinterIPs {
        didSet {
            // Update UserDefaults whenever our local value for printerIPs is updated.
            UserDefaults.standard.makerbotPrinterIPs = printerIPs
        }
    }
    
    func netServiceWillResolve(_ sender: NetService) {
        print("network service resolve about to begin")
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("network service resolve error:", sender, errorDict)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("resolved service", sender.name, sender.type)

        // Get the port data.
        var port = "9999"
        if let data = sender.txtRecordData() {
            let dict = NetService.dictionary(fromTXTRecord: data)
            if dict["port"] != nil {
                port = String(decoding: dict["port"]!, as: UTF8.self)
            }
        }
        
        // Find the IPV4 address
        if let serviceIp = resolveIPv4(addresses: sender.addresses!) {
            print("service has IPV4", serviceIp, sender.name, sender.type)
            let printerIP = serviceIp + ":" + port
            
            if let _ = self.printerIPs[printerIP] {
                print("the service already exists in our known printer IPs", printerIP, sender.name, sender.type)
            } else {
                print("adding service to list of printer IPs", printerIP, sender.name, sender.type)
                
                // Set this to an empty string since we have not authenticated the printer yet.
                self.printerIPs[printerIP] = ""
            }
        } else {
            print("did not find IPV4 address", sender.name, sender.type)
        }
    }
    
    // Find an IPv4 address from the service address data
    func resolveIPv4(addresses: [Data]) -> String? {
        var result: String?

        for addr in addresses {
            let data = addr as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)

            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                        $0.pointee
                    }
                }

                if let ip = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii) {
                    result = ip
                    break
                }
            }
        }

        return result
    }
}
