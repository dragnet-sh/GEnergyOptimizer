//
// Created by Binay Budhthoki on 12/4/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation

public enum EZone: String {
    case hvac = "HVAC", lighting = "Lighting", plugload = "PlugLoad", none

    static let getAll = [hvac, lighting, plugload]
}

public enum ERoom: String {
    case kitchen, bedroom, livingspace, hallway
    case dinningspace, watinglounge
    case none
}

public enum EStorage {
    case local, server
}

public enum DEnv: String {
    case local, prod
}

// *** Accessing Data - Local or Via Network *** //
public enum Source: String {
    case local, network
}

// *** Simplified Error Tagging *** //

enum Result <T> {
    case Success(T)
    case Error(String)
}

enum FileResource: String {
    case preaudit
}

enum EMessageType {
    case toast, alert
}

enum EntityType: String {
    case audit = "CDAudit"
    case preaudit = "CDPreAudit"
    case zone = "CDZone"
    case room = "CDRoom"
    case featureData = "CDFeatureData"
    case appliances
    case none
}


enum CellIdentifiers: String {
    case room = "roomListCell"
    case zone = "zoneListCell"
}

enum GError: Error {
    case noNetwork
    case none
}

//ToDo - Swap Label with FileName or just leave it the way it is
enum EApplianceType: String {
    case griddle = "Griddle", steamCooker = "Steam Cooker", fryer = "Fryer", hotFoodCabinets = "Hot Food Cabinets"
    case freezerFridge = "Freezer Fridge", iceMaker = "Ice Maker"
    case conveyorOven = "Conveyor Oven", convectionOven = "Convection Oven", combinationOven = "Combination Oven"
    case rackOven = "Rack Oven", none

    static let getAll = [griddle, steamCooker, fryer, hotFoodCabinets, freezerFridge, iceMaker, conveyorOven,
                         convectionOven, combinationOven, rackOven]
    static let getAllRaw = getAll.map { $0.rawValue }
    static let getDefault = getAllRaw[0]

    static func getFileName(type: EApplianceType) -> String {
        switch type {
            case .griddle: return "Griddle"
            case .steamCooker: return "SteamCooker"
            case .fryer: return "Fryer"
            case .hotFoodCabinets: return "HotFoodCabinet"
            case .freezerFridge: return "FreezerFridge"
            case .iceMaker: return "IceMaker"
            case .conveyorOven: return "ConveyorOven"
            case .convectionOven: return "ConvectionOven"
            case .combinationOven: return "CombinationOven"
            case .rackOven: return "RackOven"
            default: return "none"
        }
    }
}

enum EAction {
    case push, pop
    case create, update
}

enum ENode: Int {
    case parent = 0, child
}

enum ETagPO: String {
    case name = "po-name"
    case type = "po-appliance"
    case save = "po-save"
}

enum ERateKey: String {
    case summerOff = "summer-off-peak"
    case summerPart = "summer-part-peak"
    case summerOn = "summer-on-peak"
    case winterOff = "winter-off-peak"
    case winterPart = "winter-part-peak"

    case summerNone = "summer-none"
    case winterNone = "winter-none"

    case slab1 = "0_5.0"
    case slab2 = "5.1_16.0"
    case slab3 = "16.1_41.0"
    case slab4 = "41.1_123.0"
    case slab5 = "123.1_n_up"
    case summerTransport = "summer_first_4000_therms"
    case winterTransport = "winter_first_4000_therms"
    case surcharge

    case gasWinter, gasSummer

    case none

    static let getAllElectric = [summerOff, summerPart, summerOn, winterOff, winterPart]
    static let getAllElectricRaw = getAllElectric.map { $0.rawValue }

    static let getAllGas = [slab1, slab2, slab3, slab4, slab5, winterTransport, summerTransport, surcharge]
    static let getAllGasRaw = getAllGas.map { $0.rawValue }
}