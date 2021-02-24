//
//  FormLabs.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import Alamofire
import Combine
import Foundation

let FormLabsAPIURI = "https://api.formlabs.com/developer/v1"

class FormLabs: ObservableObject {
    var clientID: String
    var clientSecret: String
    
    var username: String = UserDefaults.standard.username
    var password: String = UserDefaults.standard.password
    @Published var token: String = UserDefaults.standard.token {
        didSet {
            // Update UserDefaults whenever our local value for token is updated.
            UserDefaults.standard.token = token
        }
    }
    var refreshToken: String = UserDefaults.standard.refreshToken {
        didSet {
            // Update UserDefaults whenever our local value for refreshToken is updated.
            UserDefaults.standard.refreshToken = refreshToken
        }
    }
    var tokenExpirationDate: Date = UserDefaults.standard.tokenExpirationDate {
        didSet {
            // Update UserDefaults whenever our local value for tokenExpirationDate is updated.
            UserDefaults.standard.tokenExpirationDate = tokenExpirationDate
        }
    }
    
    // Variables that publish items in the UI.
    @Published var printers: [Printer] = [Printer]()
    
    private var cancelableUsername: AnyCancellable?
    private var cancelablePassword: AnyCancellable?
    init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        
        self.syncPrinters()
        
        _ = Timer.scheduledTimer(
            timeInterval: 60.0, target: self,
            selector: #selector(self.syncPrinters),
            userInfo: nil,
            repeats: true)
        
        // Listen for changes to username, we need to do this
        // because the SettingsView changes username.
        cancelableUsername = UserDefaults.standard.publisher(for: \.username)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else { return }
                if newValue != self.username { // avoid cycling !!
                    self.username = newValue
                }
            })
        
        // Listen for changes to password, we need to do this
        // because the SettingsView changes password.
        cancelablePassword = UserDefaults.standard.publisher(for: \.password)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else { return }
                if newValue != self.password { // avoid cycling !!
                    self.password = newValue
                    
                    // Revoke our token just in case.
                    self.revokeToken()
                    
                    self.refreshToken = ""
                    if !self.password.isEmpty && !self.username.isEmpty {
                        // Only get the printers if we have a username and password.
                        self.getPrinters()
                    }
                }
            })
    }
    
    deinit {
        if let c = cancelableUsername {
            c.cancel()
        }
        if let c = cancelablePassword {
            c.cancel()
        }
    }
    
    func ensureValidToken() {
        // Ensure that a token is valid before performing requests.
        // Get the token if it is not already set. This will refresh the token if it
        // needs to be refreshed.
        if self.token.isEmpty || self.tokenExpirationDate <= Date() {
            self.getToken()
        }
    }
    
    func getToken() {
        let now = Date()
        
        var parameters = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "username": username,
        ]
        if self.refreshToken.isEmpty {
            // If we have a current token, let's revoke it first.
            if !self.token.isEmpty {
                self.revokeToken()
            }
            
            if self.password.isEmpty {
                // Return early, we don't have a password.
                return
            }
            
            // Set the parameters for a grant from their password.
            parameters["grant_type"] = "password"
            parameters["password"] =  self.password
        } else {
            // Set the parameters for a grant from their refreshToken.
            parameters["grant_type"] = "refresh_token"
            parameters["refresh_token"] =  self.refreshToken
        }
        
        AF.request(FormLabsAPIURI + "/o/token/", method: .post,
                   parameters: parameters,
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: [
                    .contentType("application/x-www-form-urlencoded")
                   ])
            .validate(statusCode: [200])
            .validate(contentType: ["application/json"])
            .responseDecodable(of: Token.self) { response in
                switch response.result {
                case .success:
                    if let data = response.value {
                        self.token = data.accessToken
                        self.refreshToken = data.refreshToken
                        
                        // Calculate when the token expires.
                        self.tokenExpirationDate = now.addingTimeInterval(TimeInterval(data.expiresIn))
                    } else {
                        print("getting the value for the token failed")
                    }
                case let .failure(error):
                    print("request for token failed", error)
                }
            }
    }
    
    func revokeToken() {
        if self.token.isEmpty {
            // Return early since we don't have a token.
            return
        }
        
        AF.request(FormLabsAPIURI + "/o/revoke_token/", method: .post, parameters:
                    [
                        "token": self.token,
                        "client_id": clientID,
                        "client_secret": clientSecret,
                    ],
                   encoder: URLEncodedFormParameterEncoder.default,
                   headers: [
                    .contentType("application/x-www-form-urlencoded")
                   ])
            .response { response in
                switch response.result {
                case .success:
                    self.token = ""
                    self.printers = [Printer]()
                    print("token revoked")
                case let .failure(error):
                    print("revoking token failed", error)
                }
            }
    }
    
    @objc func syncPrinters() {
        if !self.password.isEmpty && !self.username.isEmpty {
            // Only get the printers if we have a username and password.
            self.getPrinters()
        }
    }
    
    func getPrinters() {
        self.ensureValidToken()
        
        if self.token.isEmpty {
            // Return early since we don't have a token.
            return
        }
        
        AF.request(FormLabsAPIURI + "/printers/", method: .get,
                   headers: [
                    .authorization(bearerToken: self.token)
                   ])
            .validate(statusCode: [200])
            .validate(contentType: ["application/json"])
            .responseDecodable(of: [Printer].self, decoder: CustomDecoder()) { response in
                switch response.result {
                case .success:
                    if let data = response.value {
                        self.printers = data
                    } else {
                        print("getting the value for printers failed")
                    }
                case let .failure(error):
                    print("request for printers failed", error)
                }
            }
    }
}
