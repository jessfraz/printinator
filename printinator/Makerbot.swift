//
//  Makerbot.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

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
    
    var printerIPs: [String] = UserDefaults.standard.makerbotPrinterIPs {
        didSet {
            // Update UserDefaults whenever our local value for printerIPs is updated.
            UserDefaults.standard.makerbotPrinterIPs = printerIPs
        }
    }
    
    private var cancelablePrinterIPs: AnyCancellable?
    override init() {
        super.init()
        
        // Browse the network for printers.
        self.browseNetworkForPrinters()
        
        // For each printer IP we want to create a client.
        for printerIP in printerIPs {
            // Connect to the client.
            let (ip, port) = printerIP.getIPAndPort()
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            let client = TCPClient(group: eventLoopGroup, config: TCPClient.Config(framing: .brute))
            // Try to connect.
            do {
                let _ = try client.connect(host: ip, port: port).wait()
                switch try! client.call(method: "handshake", params: .none).wait() {
                    case .failure(let error):
                        fatalError("handshake failed with \(error)")
                    case .success(let response):
                        let printer = MakerbotPrinter(response)
                        print("printer", printer!)
                }
            } catch {
                print("could not connect to printer", printerIP)
            }
        }
        
        // Listen for changes to printerIPs, we need to do this
        // because the service discovery changes printerIPs.
        cancelablePrinterIPs = UserDefaults.standard.publisher(for: \.makerbotPrinterIPs)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else { return }
                if newValue != self.printerIPs { // avoid cycling !!
                    self.printerIPs = newValue
                }
            })
    }
    
    // Browse for any Makerbot printers on the network.
    func browseNetworkForPrinters() {
        // Call stop just in case we had already started.
        browser.stop()
        
        browser.delegate = self.browserAgent
        browser.searchForServices(ofType: "_makerbot-jsonrpc._tcp", inDomain: "local")
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
    var printerIPs: [String] = UserDefaults.standard.makerbotPrinterIPs {
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
            
            if !self.printerIPs.contains(printerIP) {
                print("adding service to list of printer IPs", printerIP, sender.name, sender.type)
                self.printerIPs.append(printerIP)
            } else {
                print("the service already exists in our known printer IPs", printerIP, sender.name, sender.type)
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
