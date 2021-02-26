//
//  MakerbotPrinterView.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/25/21.
//

import Foundation
import SwiftUI

struct MakerbotPrinterView: View {
    var makerbot: Makerbot
    var printer: MakerbotPrinter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image("makerbot")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 52, alignment: .leading)
                        .padding(.trailing, 10)
                    Text(printer.machineName)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .frame(width: 165, height: 26, alignment: .leading)
                    
                VStack(alignment: .trailing, spacing: 0) {
                    /*PrintStatusView(status: printer.printerStatus.status, runSuccess: "")
                        .padding(.bottom, 5)
                    Text(String(format: "%.2f°C", printer.printerStatus.currentTemperature))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .padding(.bottom, 5)*/
                    
                    if printer.token == nil || printer.token!.isEmpty {
                        MakerbotAuthPrinterView(makerbot: makerbot, printer: printer)
                    }
                    
                    if printer.lastPingedAt != nil {
                        Text("pinged " + printer.lastPingedAt!.short().lowercased())
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundColor(Color.gray)
                    }
                }
                .frame(width: 165, height: 46, alignment: .trailing)
            }
            .frame(width: 350, height: 46, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.top, 5)
        }
    }
}

struct MakerbotAuthPrinterView: View {
    var makerbot: Makerbot
    var printer: MakerbotPrinter
    @State private var overButton = false
    
    var body: some View {
        Button("Authenticate"){
            authenticate()
        }
        .background(overButton ? Color.green : Color.blue)
        .cornerRadius(2)
        .foregroundColor(Color.white)
        .padding(.bottom, 10)
        .opacity(0.8)
        .onHover { hover in
            overButton = hover
        }
    }
    
    func authenticate() {
        let alert = NSAlert()
        alert.messageText = "Authenticate " + printer.machineName

        DispatchQueue.global(qos: .background).async {
            // Authenticate the printer.
            makerbot.authenticateLocally(printer.ip, port: printer.port, name: printer.machineName)
        }
            
        alert.informativeText = "Push the knob on your printer to confirm."
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
}
