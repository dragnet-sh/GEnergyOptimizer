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

public enum ELogScope: String {
    case parse = "Parse :"
    case gemini = "GEnergy :"
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


enum EApplianceType: String {
    case griddle = "Griddle", steamCooker = "Steam Cooker", fryer = "Fryer", hotFoodCabinets = "Hot Food Cabinets"
    case freezerFridge = "Freezer Fridge", iceMaker = "Ice Maker"
    case conveyorOven = "Conveyor Oven", convectionOven = "Convection Oven", combinationOven = "Combination Oven"
    case rackOven = "Rack Oven"

    static let getAll = [griddle, steamCooker, fryer, hotFoodCabinets, freezerFridge, iceMaker, conveyorOven,
                         convectionOven, combinationOven, rackOven]
    static let getAllRaw = getAll.map { $0.rawValue }
    static let getDefault = getAllRaw[0]
}

enum Action {
    case push, pop
}

enum ENode: Int {
    case parent = 0, child
}

enum ETagPO: String {
    case name = "po-name"
    case type = "po-appliance"
    case save = "po-save"
}