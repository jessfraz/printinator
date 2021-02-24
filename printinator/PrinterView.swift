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
                        .frame(width: 20, height: 26, alignment: .leading)
                        .padding(.trailing, 10)
                    Text(printer.serial)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .frame(width: 160, height: 26, alignment: .leading)
                    
                VStack(alignment: .trailing, spacing: 0) {
                    Text(printer.printerStatus.status)
                        .foregroundColor(.blue)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .padding(.bottom, 5)
                    Text(String(format: "%.2f°C", printer.printerStatus.currentTemperature))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                }
                .frame(width: 155, height: 26, alignment: .trailing)
            }
            .frame(width: 350, height: 26, alignment: .leading)
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
            .frame(width: 190, height: 116, alignment: .leading)
            .padding(.trailing, 10)
            
            VStack(alignment: .trailing, spacing: 5) {
                    //Text(printer.printerStatus.printStartedAt)
                if printRun.printRunSuccess != nil {
                    Text(printRun.status)
                        .foregroundColor(.green)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                    
                    Text(printRun.printFinishedAt!.timeAgo() + " ago")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .frame(width: 116, alignment: .trailing)
                } else if printRun.status == "PRINTING" {
                        // The print is currently printing.
                    Text(printRun.status)
                        .foregroundColor(.blue)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                    
                    ProgressView(value: printRun.progress())
                        .padding(.top, 5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.yellow))
                   
                    Text(printRun.estimatedTimeRemainingMS.timeUntil() + " remain")
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .frame(width: 116, alignment: .trailing)
                    
                } else {
                    // The print failed or was aborted...?
                    // TODO: handle this mode.
                }
            }
        }
        .frame(width: 350, height: 100, alignment: .leading)
    }
}
