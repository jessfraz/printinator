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
                    
                        Text("last ping " + printer.printerStatus.lastPingedAt.timeAgo() + " ago")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .foregroundColor(Color.gray)
                            .frame(width: 280, height: 10, alignment: .trailing)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(width: 350, height: (270 * CGFloat(formLabs.printers.count)) + 26, alignment: .topLeading)
            }
        }
        
        Section {
            SettingsMenuView(formLabs: formLabs)
        }
    }
}
