//
//  PrinterView.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import SwiftUI

struct PrinterView: View {
    var printer: Printer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image("form3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 52, alignment: .leading)
                        .padding(.trailing, 10)
                    Text(printer.serial)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .frame(width: 160, height: 26, alignment: .leading)
                    
                VStack(alignment: .trailing, spacing: 0) {
                    PrintStatusView(status: printer.printerStatus.status, runSuccess: "")
                        .padding(.bottom, 5)
                    Text(String(format: "%.2f°C", printer.printerStatus.currentTemperature))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .padding(.bottom, 5)
                    Text("last ping " + printer.printerStatus.lastPingedAt.short().lowercased())
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(Color.gray)
                }
                .frame(width: 155, height: 46, alignment: .trailing)
            }
            .frame(width: 350, height: 46, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.top, 5)
            
            if printer.printerStatus.currentPrintRun != nil {
                PrintRunView(printRun: printer.printerStatus.currentPrintRun!)
            }
            
            if printer.previousPrintRun != nil {
                PrintRunView(printRun: printer.previousPrintRun!)
            }
        }
    }
}

struct PrintRunView: View {
    var printRun: PrintRun
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 10) {
                    Image(nsImage: printRun.thumbnail())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 116, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(printRun.name)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
            
                        HStack {
                            Text(printRun.materialName)
                                .frame(height: 19, alignment: .bottom)
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                            printRun.droplet()
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 17, alignment: .top)
                        }
                    }
                }
                .frame(width: 200, height: 116, alignment: .leading)
                .padding(.trailing, 0)
            
                VStack(alignment: .trailing, spacing: 5) {
                    PrintStatusView(status: printRun.status, runSuccess: printRun.printRunSuccess?.printRunSuccess ?? "")
                        .frame(width: 116, alignment: .trailing)
                    if printRun.printFinishedAt != nil {
                        Text(printRun.printFinishedAt!.timeAgo() + " ago")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .frame(width: 116, alignment: .trailing)
                    }
                
                    if printRun.status == "PRINTING" {
                        Text(printRun.estimatedTimeRemainingMS.timeUntil() + " remain")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .frame(width: 116, alignment: .trailing)
                    }
                }
            }
            .frame(width: 350, height: 100, alignment: .leading)
            
            if printRun.status == "PRINTING" {
                ProgressView(value: printRun.progress())
                    .frame(width: 318, alignment: .leading)
            }
        }
        .frame(width: 350, height: 100, alignment: .leading)
    }
}

struct PrintStatusView: View {
    var status: String
    var runSuccess: String
    
    var body: some View {
        Text(status)
            .foregroundColor((runSuccess.isEmpty) ? status.getStatusColor() : runSuccess.getStatusColor())
            .font(.system(size: 12, weight: .bold, design: .monospaced))
    }
}
