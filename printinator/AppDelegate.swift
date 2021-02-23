//
//  AppDelegate.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import Cocoa
import SwiftUI

@available(OSX 11.0, *)
@main
struct MenuBarPopoverApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings{
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status item.
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.title = "3D Printers"
            button.action = #selector(togglePopover(_:))
        }
        
        // Initialize FormLabs.
        
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 1000)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                let sizeThatFits = (self.popover.contentViewController as? NSHostingController<ContentView>)?.sizeThatFits(in: CGSize(width: 350, height: 0))
                if sizeThatFits != nil {
                    self.popover.contentSize = sizeThatFits!
                }
                
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
