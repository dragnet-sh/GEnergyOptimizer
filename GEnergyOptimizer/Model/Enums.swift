//
// Created by Binay Budhthoki on 12/4/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation


public enum EZone: String {
    case hvac = "HVAC", lighting = "Lighting", plugload = "PlugLoad"
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
