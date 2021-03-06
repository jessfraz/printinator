//
//  FormLabsTypes.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import Foundation
import SwiftUI

struct Token: Codable {
    let accessToken, tokenType: String
    let expiresIn: Int
    let refreshToken, scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

struct Printer: Codable {
    let serial, machineTypeID: String
    let totalPrintTimeMS, totalNumberOfPrints: Int
    let printerStatus: PrinterStatus
    let cartridgeStatus: CartridgeStatus
    let tankStatus: TankStatus?
    let group: String?
    let previousPrintRun: PrintRun?

    enum CodingKeys: String, CodingKey {
        case serial
        case machineTypeID = "machine_type_id"
        case totalPrintTimeMS = "total_print_time_ms"
        case totalNumberOfPrints = "total_number_of_prints"
        case printerStatus = "printer_status"
        case cartridgeStatus = "cartridge_status"
        case tankStatus = "tank_status"
        case group
        case previousPrintRun = "previous_print_run"
    }
}

extension Printer {
    // Get the icon string for the printer type.
    func getIcon() -> String {
        var icon = "fuse"
        let type = self.machineTypeID.lowercased()
           
        if type.contains("form-3l") {
            icon = "form3l"
        } else if type.contains("form-3b") {
            icon = "form3b"
        } else if type.contains("form-3") {
            icon = "form3"
        }
            
        return icon
    }
}

struct CartridgeStatus: Codable {
    let cartridge: Cartridge
    let cartridgeSlot: String
    let lastModified: Date

    enum CodingKeys: String, CodingKey {
        case cartridge
        case cartridgeSlot = "cartridge_slot"
        case lastModified = "last_modified"
    }
}

struct Cartridge: Codable {
    let serial, material: String
    let initialVolumeMl: Int
    let volumeDispensedMl: Double
    let lastDispenseAt: Date?
    let dispenseCount: Int?
    let isEmpty: Bool
    let insidePrinter: String
    let displayName, connectedGroup: String?
    let createdAt, lastPrintDate: Date

    enum CodingKeys: String, CodingKey {
        case serial, material
        case initialVolumeMl = "initial_volume_ml"
        case volumeDispensedMl = "volume_dispensed_ml"
        case lastDispenseAt = "last_dispense_at"
        case dispenseCount = "dispense_count"
        case isEmpty = "is_empty"
        case insidePrinter = "inside_printer"
        case displayName = "display_name"
        case connectedGroup = "connected_group"
        case createdAt = "created_at"
        case lastPrintDate = "last_print_date"
    }
}

extension Cartridge {
    func materialRemaining() -> String {
        let remaining = Double(initialVolumeMl) - volumeDispensedMl
        return String(format: "%.2f ml remain", remaining)
    }
}

struct PrinterStatus: Codable {
    let currentPrintRun: PrintRun?
    let status: String
    let lastModified, lastPingedAt: Date
    let currentTemperature: Float
    let hopperLevel: JSONNull?

    enum CodingKeys: String, CodingKey {
        case currentPrintRun = "current_print_run"
        case status
        case lastModified = "last_modified"
        case lastPingedAt = "last_pinged_at"
        case currentTemperature = "current_temperature"
        case hopperLevel = "hopper_level"
    }
}

struct TankStatus: Codable {
    let tank: Tank
    let lastModified: Date

    enum CodingKeys: String, CodingKey {
        case tank
        case lastModified = "last_modified"
    }
}

struct Tank: Codable {
    let serial, material: String
    let printTimeMS, layerCount, layersPrinted: Int
    let insidePrinter, tankType: String
    let heatmap, heatmapGif: JSONNull?
    let displayName, connectedGroup: String?
    let firstFillDate: String? // For some reason this one comes back in a different format.
    let createdAt, lastPrintDate: Date

    enum CodingKeys: String, CodingKey {
        case serial, material
        case printTimeMS = "print_time_ms"
        case layerCount = "layer_count"
        case layersPrinted = "layers_printed"
        case insidePrinter = "inside_printer"
        case tankType = "tank_type"
        case heatmap
        case heatmapGif = "heatmap_gif"
        case displayName = "display_name"
        case connectedGroup = "connected_group"
        case createdAt = "created_at"
        case firstFillDate = "first_fill_date"
        case lastPrintDate = "last_print_date"
    }
}

extension Tank {
    func layersStatus() -> String {
        // Tanks last for 75000 layers.
        let maxLayers = 75000
        
        return String(format: "%d / %d layers", self.layersPrinted, maxLayers)
    }
    
    func daysStatus() -> String {
        // Tanks last for 250 days.
        let maxDays = 250
        let diffInDays = Calendar.current.dateComponents([.day], from: self.createdAt, to: Date()).day
        
        return String(format: "%d / %d days used", diffInDays!, maxDays)
    }
}

struct PrintRun: Codable {
    let guid, name, printer, status: String
    let usingOpenMode, probablyFinished: Bool
    let zHeightOffsetMM: Float
    let printStartedAt: Date
    let printFinishedAt: Date?
    let layerCount: Int
    let volumeML: Float
    let material, materialName: String
    let layerThicknessMM: Float
    let currentlyPrintingLayer, estimatedDurationMS, elapsedDurationMS, estimatedTimeRemainingMS: Int
    let createdAt: Date
    let printRunSuccess: PrintRunSuccessVote?
    let firmwareVersion, cartridge, tank: String
    let user: User
    let message: String?
    let note: JSONNull?
    let printThumbnail: PrintThumbnail
    let feedback: JSONNull?
    let userCustomLabel: String
    let adaptiveThickness: Bool
    let cylinder: JSONNull?
    let group: String?
    let printJob: JSONNull?

    enum CodingKeys: String, CodingKey {
        case guid, name, printer, status
        case usingOpenMode = "using_open_mode"
        case probablyFinished = "probably_finished"
        case zHeightOffsetMM = "z_height_offset_mm"
        case printStartedAt = "print_started_at"
        case printFinishedAt = "print_finished_at"
        case layerCount = "layer_count"
        case volumeML = "volume_ml"
        case material
        case materialName = "material_name"
        case layerThicknessMM = "layer_thickness_mm"
        case currentlyPrintingLayer = "currently_printing_layer"
        case estimatedDurationMS = "estimated_duration_ms"
        case elapsedDurationMS = "elapsed_duration_ms"
        case estimatedTimeRemainingMS = "estimated_time_remaining_ms"
        case createdAt = "created_at"
        case printRunSuccess = "print_run_success"
        case firmwareVersion = "firmware_version"
        case cartridge, tank
        case user, message, note
        case printThumbnail = "print_thumbnail"
        case feedback
        case userCustomLabel = "user_custom_label"
        case adaptiveThickness = "adaptive_thickness"
        case cylinder, group
        case printJob = "print_job"
    }
}

extension PrintRun {
    // Turn the URL for the player's avatar into an NSImage.
    func thumbnail() -> NSImage {
        let url = URLComponents(string: self.printThumbnail.thumbnail)?.url
        if let data = try? Data.init(contentsOf: url!, options: []) {
            let avatar = NSImage(data: data)!
            avatar.size = NSSizeFromString("500,500")
            return avatar
        }
        return NSImage()
    }
    
    // Get the progress of the run.
    func progress() -> Double {
        return (Double(self.currentlyPrintingLayer) / Double(self.layerCount))
    }
    
    // Return the droplet image for the material used.
    func droplet() -> Image {
        return self.materialName.droplet()
    }
}

struct PrintRunSuccessVote: Codable {
    let printRun, printRunSuccess: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case printRun = "print_run"
        case printRunSuccess = "print_run_success"
        case createdAt = "created_at"
    }
}

struct PrintThumbnail: Codable {
    let thumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case thumbnail
    }
}

struct User: Codable {
    let email, firstName: String
    let id: Int
    let lastName, username: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case id
        case lastName = "last_name"
        case username
    }
}

class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class CustomDecoder: JSONDecoder {
    let RFC3339DateFormatter = DateFormatter()
    
    override init() {
        super.init()
        
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // The date strings returned by the API are in the format: "2021-02-23T07:33:31.403593-05:00"
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateDecodingStrategy = .formatted(RFC3339DateFormatter)
    }
}

extension Date {
    func timeAgo() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
    
    func dayString() -> String {
        let calendar = Calendar.current
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
        let day = components.day!
        if abs(day) < 2 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: self)
        } else if day > 1 {
            return "In \(day) days"
        } else {
            return "\(-day) days ago"
        }
    }
    
    func short() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return self.dayString() + " at " + formatter.string(from: self)
    }
}

extension Int {
    func timeUntil() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: Date(), to: Date().addingTimeInterval(TimeInterval(self / 1000))) ?? "", locale: .current)
    }
}

extension String {
    func getStatusColor() -> Color {
        switch self {
        case "PRINTING":
            return Color.blue
        case "FINISHED":
            return Color.green
        case "SUCCESS":
            return Color.green
        case "IDLE":
            return Color.yellow
        case "ABORTED":
            return Color.red
        case "UNKNOWN":
            return Color.orange
        case "FAILED":
            return Color.red
        default:
            return Color.blue
        }
    }
}

extension String {
    func getMaterialName() -> String {
        switch self {
        case "FLGPBK04":
            return "Black V4"
        case "FLFL8001":
            return "Flexible 80A"
        default:
            return "Color V1"
        }
    }
    
    func getTankName() -> String {
        switch self {
        case "TANK_TYPE_DAGUERRE_V2":
            return "Tank V2"
        case "TANK_TYPE_PDMS":
            return "Tank V2.1"
        default:
            return "Tank V1"
        }
    }
    
    // Return the droplet image for the material used.
    func droplet() -> Image {
        var droplet = "droplet_color"
        let material = self.lowercased()
        
        if material.contains("nylon") {
            droplet = "powder_nylon"
        } else if material.contains("draft v1") {
            droplet = "droplet_draft_v1"
        } else if material.contains("draft v2") {
            droplet = "droplet_draft_v2"
        } else if material.contains("biomed amber") {
            droplet = "droplet_biomed_amber"
        } else if material.contains("biomed clear") {
            droplet = "droplet_biomed_clear"
        } else if material.contains("black") {
            droplet = "droplet_black"
        } else if material.contains("castable wax 40") {
            droplet = "droplet_castable_wax_40_v1"
        } else if material.contains("castable wax") {
            droplet = "droplet_castable_wax_v1"
        } else if material.contains("castable") {
            droplet = "droplet_castable_v2"
        } else if material.contains("ceramic") {
            droplet = "droplet_ceramic"
        } else if material.contains("clear") {
            droplet = "droplet_clear"
        } else if material.contains("custom tray") {
            droplet = "droplet_custom_tray"
        } else if material.contains("dental lt clear v1") {
            droplet = "droplet_dental_lt_clear_v1"
        } else if material.contains("dental lt clear") {
            droplet = "droplet_dental_lt_clear_v2"
        } else if material.contains("dental model") {
            droplet = "droplet_dental_model_v1"
        } else if material.contains("dental sg") {
            droplet = "droplet_dental_sg_v1"
        } else if material.contains("denture base dp") {
            droplet = "droplet_denture_base_dp"
        } else if material.contains("denture base lp") {
            droplet = "droplet_denture_base_lp"
        } else if material.contains("denture base op") {
            droplet = "droplet_denture_base_op"
        } else if material.contains("denture base") {
            droplet = "droplet_denture_base_rp"
        } else if material.contains("denture teeth a1") {
            droplet = "droplet_denture_teeth_a1"
        } else if material.contains("denture teeth a2") {
            droplet = "droplet_denture_teeth_a2"
        } else if material.contains("denture teeth a3.5") {
            droplet = "droplet_denture_teeth_a3.5"
        } else if material.contains("denture teeth a3") {
            droplet = "droplet_denture_teeth_a3"
        } else if material.contains("denture teeth b1") {
            droplet = "droplet_denture_teeth_b1"
        } else if material.contains("denture teeth") {
            droplet = "droplet_denture_teeth_b2"
        } else if material.contains("draft v1") {
            droplet = "droplet_draft_v1"
        } else if material.contains("draft") {
            droplet = "droplet_draft_v2"
        } else if material.contains("durable") {
            droplet = "droplet_durable"
        } else if material.contains("elastic") {
            droplet = "droplet_elastic_v1"
        } else if material.contains("flexible 80") {
            droplet = "droplet_flexible_80a"
        } else if material.contains("flexible") {
            droplet = "droplet_flexible_v2"
        } else if material.contains("grey pro") {
            droplet = "droplet_grey_pro_v1"
        } else if material.contains("grey") {
            droplet = "droplet_grey_v3"
        } else if material.contains("high temp v1") {
            droplet = "droplet_high_temp_v1"
        } else if material.contains("high temp") {
            droplet = "droplet_high_temp_v2"
        } else if material.contains("rigid 10k") {
            droplet = "droplet_rigid_10k"
        } else if material.contains("rigid") {
            droplet = "droplet_rigid"
        } else if material.contains("surgical") {
            droplet = "droplet_surgical_guide"
        } else if material.contains("temp cb a2") {
            droplet = "droplet_temp_cb_a2"
        } else if material.contains("temp cb a3") {
            droplet = "droplet_temp_cb_a3"
        } else if material.contains("temp cb b1") {
            droplet = "droplet_temp_cb_b1"
        } else if material.contains("temp cb c2") {
            droplet = "droplet_temp_cb_c2"
        } else if material.contains("tough 1500") {
            droplet = "droplet_tough_1500_v1"
        } else if material.contains("tough 1500") {
            droplet = "droplet_tough_1500_v1"
        } else if material.contains("tough 2000") {
            droplet = "droplet_tough_2000_v1"
        } else if material.contains("tough v4") {
            droplet = "droplet_tough_v4"
        } else if material.contains("tough") {
            droplet = "droplet_tough_v5"
        } else if material.contains("white") {
            droplet = "droplet_white"
        }
        
        return Image(droplet)
    }
}
