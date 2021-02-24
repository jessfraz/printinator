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
        if !formLabs.token.isEmpty {
            Section {
                List(formLabs.printers, id: \.serial) { printer in
                    VStack {
                        PrinterView(printer: printer)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(width: 350, height: (260 * CGFloat(formLabs.printers.count)) + 50, alignment: .topLeading)
            }
        }
        
        Section {
            SettingsMenuView(formLabs: formLabs)
        }
    }
}
