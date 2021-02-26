//
//  MakerbotService.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

import Foundation

struct MakerbotPrinter: Codable {
    init?(_ object: RPCObject) {
        let data = getDataFromRPCObject(object)
        
        if data != nil {
            // Parse the JSON.
            // FIXME: actually check for errors here.
            let json: MakerbotPrinter = try! JSONDecoder().decode(MakerbotPrinter.self, from: data!)
            self = json
            return
        }
        
        return nil
    }
    
    let machineType: String          // The codename for this machine type
    let vid: Int                     // Vendor ID of the printer
    let ip: String                   // The local IP of this printer
    let pid: Int                     // Product ID of the printer
    let apiVersion: String           // API verison
    let serial: String               // Serial number of the printer
    let sslPort: String              // Port at which the HTTPS server can be accessed
    let machineName: String          // User-defined printer name
    let motorDriverVersion: String   // Version number of the motor driver
    let botType: String              // Codename for the bot type
    let port: String                 // JSON-RPC port (usually 9999)
    let firmwareVersion: MakerbotFirmwareVersion
    var token: String?
    var lastPingedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case machineType = "machine_type"
        case vid, ip, pid
        case apiVersion = "api_version"
        case serial = "iserial"
        case sslPort = "ssl_port"
        case machineName = "machine_name"
        case motorDriverVersion = "motor_driver_version"
        case botType = "bot_type"
        case port
        case firmwareVersion = "firmware_version"
        case token
        case lastPingedAt = "last_pinged_at"
    }
}

struct MakerbotFirmwareVersion: Codable {
    let major: Int
    let minor: Int
    let bugfix: Int
    let build: Int
}

struct MakerbotAuthResponse: Codable {
    let answer: String?
    let code: String?
    let answerCode: String?
    let accessToken: String?
    
    enum CodingKeys: String, CodingKey {
        case answer, code
        case answerCode = "answer_code"
        case accessToken = "access_token"
    }
}

extension String {
    func getIPAndPort() -> (String, Int){
        let components = self.components(separatedBy: ":")
        return (components[0], Int(components[1]) ?? 9999)
    }
    
    func getMakerbotAuthURL() -> String {
        // Most of these listen on port 80 over http.
        return "http://" + self + "/auth"
    }
}

func getDataFromRPCObject(_ object: RPCObject) -> Data? {
    var data: Data?
    
    switch object {
        case .dictionary(let json):
            var map: [String: Any] = [String: Any]()
            for (key, value) in json {
                var v: Any
                switch value {
                    case .string(let k):
                        v = String(k)
                    case .integer(let k):
                        v = Int(k)
                    case .double(let k):
                        v = Double(k)
                    case .bool(let k):
                        v = Bool(k)
                    case .dictionary(let k):
                        var inner_map: [String: Any] = [String: Any]()
                        for (i, j) in k {
                            var t: Any
                            switch j {
                                case .string(let k):
                                    t = String(k)
                                case .integer(let k):
                                    t = Int(k)
                                case .double(let k):
                                    t = Double(k)
                                case .bool(let k):
                                    t = Bool(k)
                                default:
                                    t = value
                            }
                            
                            inner_map[i] = t
                        }
                        v = inner_map
                    default:
                        v = value
                }
                
                map[key] = v
            }
            
            data = try! JSONSerialization.data(withJSONObject: map, options: [])
        default:
            // TODO: find a better way to handle the default case
            return data
    }
    
    return data
}
