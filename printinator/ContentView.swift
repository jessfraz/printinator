//
//  ContentView.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var formLabs: FormLabs
    @ObservedObject var makerbot: Makerbot
    
    var body: some View {
        if !formLabs.token.isEmpty && !formLabs.username.isEmpty {
            if formLabs.printers.count > 0 {
                Section {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(formLabs.printers, id: \.serial) { printer in
                            VStack {
                                PrinterView(printer: printer)
                            }
                            .frame(width: 350, alignment: .topLeading)
                        }
                        .padding(10)
                    }
                    .frame(width: 350, height: (430 * CGFloat(formLabs.printers.count)), alignment: .topLeading)
                }
            } else {
                Section {
                    Text("Fetching formlabs printers...")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                
                    LoadingView()
                }
                .frame(width: 350, height: 50, alignment: .center)
            }
        }
        
        if makerbot.printers.count > 0 {
            Section {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(makerbot.printers, id: \.serial) { printer in
                        VStack {
                            MakerbotPrinterView(makerbot: makerbot, printer: printer)
                        }
                        .frame(width: 350, alignment: .topLeading)
                    }
                    .padding(10)
                }
                .frame(width: 350, height: (430 * CGFloat(makerbot.printers.count)), alignment: .topLeading)
            }
        }
        
        Section {
            SettingsMenuView(formLabs: formLabs)
        }
    }
}
