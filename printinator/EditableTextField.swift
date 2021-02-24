//
//  EditableTextField.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/24/21.
//

import Foundation
import SwiftUI

class EditableNSTextField: NSTextField {
    private let commandKey = NSEvent.ModifierFlags.command.rawValue
    private let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
                default:
                    break
                }
            } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}

struct EditableTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    let onCommit: () -> Void
    
    func makeNSView(context: Context) -> EditableNSTextField {
        let textField = EditableNSTextField()
        textField.placeholderAttributedString = NSAttributedString(
            string: placeholder,
            attributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)]
        )
        textField.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textField.delegate = context.coordinator
        
        return textField
    }

    func updateNSView(_ nsView: EditableNSTextField, context: Context) {
        nsView.stringValue = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
            let parent: EditableTextField

            init(_ textField: EditableTextField) {
                self.parent = textField
            }

            func controlTextDidEndEditing(_ obj: Notification) {
                self.parent.onCommit()
            }

            func controlTextDidChange(_ obj: Notification) {
                guard let textField = obj.object as? NSTextField else { return }
                self.parent.text = textField.stringValue
            }
        }
}

