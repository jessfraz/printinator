//
//  SettingsView.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import Foundation
import SwiftUI

struct SettingsMenuView: View {
    @AppStorage("username") private var username = UserDefaults.standard.username
    @AppStorage("password") private var password = UserDefaults.standard.password
    @ObservedObject var formLabs: FormLabs
    
    @State var usernameInput = UserDefaults.standard.username
    @State var passwordInput = ""

    var body: some View {
        Section {
            if !username.isEmpty && !password.isEmpty {
                Menu("Settings") {
                    Text("Logged in as " + username)
                    Button("Logout") {
                        logout()
                    }
                
                    Button("Quit") {
                        quit()
                    }
                }
                .menuStyle(BorderlessButtonMenuStyle())
            } else {
                Form {
                    Text("Settings")
                        .font(.title)
                    Section(header: Text("FORMLABS")) {
                        TextField("Enter your username", text: $usernameInput, onCommit: {
                            self.formLabs.username = self.usernameInput
                            self.username = self.usernameInput
                        })
                        .disableAutocorrection(true)
                        .focusable()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        
                        // TODO: enable pasting into thing field.
                        TextField("Enter your password", text: $passwordInput, onCommit: {
                            self.formLabs.password = self.passwordInput
                            self.password = self.passwordInput
                            
                            // Revoke our token just in case.
                            self.formLabs.revokeToken()
                            
                            if !self.passwordInput.isEmpty {
                                self.formLabs.getPrinters()
                            }
                        })
                        .disableAutocorrection(true)
                        .focusable()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                    }
                    .padding(.top, 10)
                }
                
                Text("You will automatically be signed in after entering your credentials.")
                    .lineLimit(2)
                    .frame(width: 350, height: 35, alignment: .leading)
                
                Button("Quit Application") {
                    quit()
                }
                .buttonStyle(LinkButtonStyle())
                .disabled(false)
            }
        }
        .padding(10)
    }
    
    func logout() {
        // Nullify the username and password, as well as the printers.
        self.password = ""
        self.formLabs.printers = [Printer]()
        
        self.formLabs.revokeToken()
        
    }
    
    func quit() {
        exit(0)
    }
}
