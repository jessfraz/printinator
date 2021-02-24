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
                        EditableTextField(placeholder: "Enter your username", text: $usernameInput, onCommit: {
                            self.formLabs.username = self.usernameInput
                            self.username = self.usernameInput
                        })
                        
                        EditableSecureTextField(placeholder: "Enter your password", text: $passwordInput, onCommit: {
                            self.formLabs.password = self.passwordInput
                            self.password = self.passwordInput
                            
                            // Revoke our token just in case.
                            self.formLabs.revokeToken()
                            
                            if !self.password.isEmpty {
                                self.formLabs.getPrinters()
                            }
                        })
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
        // Nullify the password and revoke the token.
        self.password = ""
        
        self.formLabs.revokeToken()
    }
    
    func quit() {
        exit(0)
    }
}
