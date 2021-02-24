//
//  ContentView.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var formLabs: FormLabs
    
    var body: some View {
        if !formLabs.token.isEmpty && !formLabs.username.isEmpty {
            if formLabs.printers.count > 0 {
                Section {
                    List(formLabs.printers, id: \.serial) { printer in
                        VStack {
                            PrinterView(printer: printer)
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .frame(width: 350, height: (260 * CGFloat(formLabs.printers.count)) + 50, alignment: .topLeading)
                }
            } else {
                Section {
                    Text("Fetching printers...")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                
                    LoadingView()
                }
                .frame(width: 350, height: 50, alignment: .center)
            }
        }
        
        Section {
            SettingsMenuView(formLabs: formLabs)
        }
    }
}
