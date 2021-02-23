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
    var appDelegate : AppDelegate
    let clientID = "{STICK YOUR CLIENT ID HERE}"
    let clientSecret = "{STICK YOUR CLIENT SECRET HERE}"
    
    var username: String = UserDefaults.standard.username
    var password: String = UserDefaults.standard.password
    var token: String = UserDefaults.standard.token {
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
    init(_ appd: AppDelegate) {
        self.appDelegate = appd
        
        if !self.password.isEmpty && !self.username.isEmpty {
            // Only get the printers if we have a username and password.
            self.getPrinters()
        }
        
        // Listen for changes to username, we need to do this
        // because the SettingsView changes username.
        cancelableUsername = UserDefaults.standard.publisher(for: \.username)
            // Wait for a pause in the delivery of events from the upstream publisher.
            // Only receive elements when the user pauses or stops typing.
            // When they start typing again, the debounce holds event delivery until the next pause.
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else { return }
                if newValue != self.username { // avoid cycling !!
                    self.username = newValue
                }
            })
        
        // Listen for changes to password, we need to do this
        // because the SettingsView changes password.
        cancelablePassword = UserDefaults.standard.publisher(for: \.password)
            // Wait for a pause in the delivery of events from the upstream publisher.
            // Only receive elements when the user pauses or stops typing.
            // When they start typing again, the debounce holds event delivery until the next pause.
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else { return }
                if newValue != self.password { // avoid cycling !!
                    self.password = newValue
                    self.token = ""
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
                    print("token revoked")
                case let .failure(error):
                    print("revoking token failed", error)
                }
            }
    }
    
    func getPrinters() {
        self.ensureValidToken()
        
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
                        print(self.printers)
                    } else {
                        print("getting the value for printers failed")
                    }
                case let .failure(error):
                    print("request for printers failed", error)
                }
            }
    }
}
