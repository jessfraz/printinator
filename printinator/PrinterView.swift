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
                        .frame(height: 52, alignment: .leading)
                        .padding(.trailing, 10)
                    Text(printer.serial)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                .frame(width: 165, height: 26, alignment: .leading)
                    
                VStack(alignment: .trailing, spacing: 0) {
                    PrintStatusView(status: printer.printerStatus.status, runSuccess: "")
                        .padding(.bottom, 5)
                    Text(String(format: "%.2f°C", printer.printerStatus.currentTemperature))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .padding(.bottom, 5)
                    Text("pinged " + printer.printerStatus.lastPingedAt.short().lowercased())
                        .font(.system(size: 9, weight: .regular, design: .monospaced))
                        .foregroundColor(Color.gray)
                }
                .frame(width: 165, height: 46, alignment: .trailing)
            }
            .frame(width: 350, height: 46, alignment: .leading)
            .padding(.bottom, 20)
            .padding(.top, 5)
            
            HStack(alignment: .top, spacing: 0) {
                PrinterCartridgeView(cartridgeStatus: printer.cartridgeStatus)
            
                PrinterTankView(tankStatus: printer.tankStatus)
            }
            .padding(.bottom, 20)
            
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
        GroupBox{
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(printRun.name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .padding(0)
            
                    Image(nsImage: printRun.thumbnail())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 65, alignment: .leading)
                        .padding(0)
                }
                .frame(width: 190, alignment: .leading)
                .padding(10)
            
                VStack(alignment: .trailing, spacing: 5) {
                    PrintStatusView(status: printRun.status, runSuccess: printRun.printRunSuccess?.printRunSuccess ?? "")
                    
                    if printRun.status == "PRINTING" {
                        ProgressView(value: printRun.progress())
                            .frame(width: 100, alignment: .leading)
                    }
                    
                    if printRun.printFinishedAt != nil {
                        Text(printRun.printFinishedAt!.timeAgo() + " ago")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                    }
                
                    if printRun.status == "PRINTING" {
                        Text(printRun.estimatedTimeRemainingMS.timeUntil() + " remain")
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                    }
                    
                    PrintMaterialView(printRun: printRun)
                }
                .frame(width: 100, alignment: .topTrailing)
                .padding(.trailing, 10)
                .padding(.top, 10)
            }
        }
        .frame(width: 330, alignment: .leading)
        .padding(.bottom, 10)
    }
}

struct PrintMaterialView: View {
    var printRun: PrintRun
    
    var body: some View {
        HStack {
            printRun.droplet()
                .resizable()
                .scaledToFit()
                .frame(height: 16, alignment: .center)
            
            Text(printRun.materialName)
                .frame(height: 16, alignment: .center)
                .font(.system(size: 12, weight: .regular, design: .rounded))
        }
        .padding(.top, 5)
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

struct PrinterCartridgeView: View {
    var cartridgeStatus: CartridgeStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .center, spacing: 0) {
                cartridgeStatus.cartridge.material.getMaterialName().droplet()
                    .resizable()
                    .scaledToFit()
                    .frame(height: 14, alignment: .leading)
                    .padding(.trailing, 10)
                Text(cartridgeStatus.cartridge.material.getMaterialName())
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
                
            Text(cartridgeStatus.cartridge.materialRemaining())
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
            /*Text("updated " + cartridgeStatus.cartridge.createdAt.short().lowercased())
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundColor(Color.gray)*/
        }
        .frame(width: 155, alignment: .leading)
        .padding(.trailing, 10)
    }
}

struct PrinterTankView: View {
    var tankStatus: TankStatus
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 5) {
            HStack(alignment: .center, spacing: 0) {
                Image("tank")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 14, alignment: .leading)
                    .padding(.trailing, 10)
                
                Text(tankStatus.tank.tankType.getTankName())
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
                
            Text(tankStatus.tank.layersStatus())
                .font(.system(size: 10, weight: .regular, design: .monospaced))
            Text(tankStatus.tank.daysStatus())
                .font(.system(size: 10, weight: .regular, design: .monospaced))
            Text("updated " + tankStatus.lastModified.short().lowercased())
                .font(.system(size: 9, weight: .regular, design: .monospaced))
                .foregroundColor(Color.gray)
        }
        .frame(width: 165, alignment: .trailing)
    }
}
