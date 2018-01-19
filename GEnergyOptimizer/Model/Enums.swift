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
    case none
}


enum CellIdentifiers: String {
    case room = "roomListCell"
    case zone = "zoneListCell"
}
