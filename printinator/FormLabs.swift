//
//  FormLabs.swift
//  printinator
//
//  Created by Jessie Frazelle on 2/23/21.
//

import Foundation

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
    let tankStatus: TankStatus

    enum CodingKeys: String, CodingKey {
        case serial
        case machineTypeID = "machine_type_id"
        case totalPrintTimeMS = "total_print_time_ms"
        case totalNumberOfPrints = "total_number_of_prints"
        case printerStatus = "printer_status"
        case cartridgeStatus = "cartridge_status"
        case tankStatus = "tank_status"
    }
}

struct CartridgeStatus: Codable {
    let cartridge: Cartridge
    let lastModified: String

    enum CodingKeys: String, CodingKey {
        case cartridge
        case lastModified = "last_modified"
    }
}

struct Cartridge: Codable {
    let serial, material: String
    let initialVolumeMl: Int
    let volumeDispensedMl: Double
    let lastDispenseAt: JSONNull?
    let dispenseCount: Int
    let isEmpty: Bool
    let insidePrinter: String

    enum CodingKeys: String, CodingKey {
        case serial, material
        case initialVolumeMl = "initial_volume_ml"
        case volumeDispensedMl = "volume_dispensed_ml"
        case lastDispenseAt = "last_dispense_at"
        case dispenseCount = "dispense_count"
        case isEmpty = "is_empty"
        case insidePrinter = "inside_printer"
    }
}

struct PrinterStatus: Codable {
    let currentPrintRun: PrintRun
    let status, lastModified, lastPingedAt: String
    let currentTemperature: JSONNull?
    let printer: String

    enum CodingKeys: String, CodingKey {
        case currentPrintRun = "current_print_run"
        case status
        case lastModified = "last_modified"
        case lastPingedAt = "last_pinged_at"
        case currentTemperature = "current_temperature"
        case printer
    }
}

struct TankStatus: Codable {
    let tank: Tank
    let lastModified: String

    enum CodingKeys: String, CodingKey {
        case tank
        case lastModified = "last_modified"
    }
}

struct Tank: Codable {
    let serial, material: String
    let printTimeMS, layerCount: Int
    let insidePrinter, tankType: String

    enum CodingKeys: String, CodingKey {
        case serial, material
        case printTimeMS = "print_time_ms"
        case layerCount = "layer_count"
        case insidePrinter = "inside_printer"
        case tankType = "tank_type"
    }
}

struct PrintRun: Codable {
    let guid, name, printer, status: String
    let usingOpenMode: Bool
    let zHeightOffsetMM: Float
    let printStartedAt, printFinishedAt: String
    let layerCount: Int
    let volumeML: Float
    let material: String
    let layerThicknessMM: Float
    let currentlyPrintingLayer, estimatedDurationMS, elapsedDurationMS, estimatedTimeRemainingMS: Int
    let createdAt: String
    let printRunSuccess: PrintRunSuccessVote
    let firmwareVersion, cartridge, tank: String
    let user: JSONNull?
    let note: JSONNull?
    let printThumbnail: JSONNull?
    let feedback: JSONNull?
    let userCustomLabel: String

    enum CodingKeys: String, CodingKey {
        case guid, name, printer, status
        case usingOpenMode = "using_open_mode"
        case zHeightOffsetMM = "z_height_offset_mm"
        case printStartedAt = "print_started_at"
        case printFinishedAt = "print_finished_at"
        case layerCount = "layer_count"
        case volumeML = "volume_ml"
        case material
        case layerThicknessMM = "layer_thickness_mm"
        case currentlyPrintingLayer = "currently_printing_layer"
        case estimatedDurationMS = "estimated_duration_ms"
        case elapsedDurationMS = "elapsed_duration_ms"
        case estimatedTimeRemainingMS = "estimated_time_remaining_ms"
        case createdAt = "created_at"
        case printRunSuccess = "print_run_success"
        case firmwareVersion = "firmware_version"
        case cartridge, tank
        case user, note
        case printThumbnail = "print_thumbnail"
        case feedback
        case userCustomLabel = "user_custom_label"
    }
}

struct PrintRunSuccessVote: Codable {
    let printRun, printRunSuccess, createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case printRun = "print_run"
        case printRunSuccess = "print_run_success"
        case createdAt = "created_at"
    }
}

class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
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
