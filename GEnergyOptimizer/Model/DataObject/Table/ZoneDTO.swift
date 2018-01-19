//
// Created by Binay Budhthoki on 1/11/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class ZoneListDTO {
    var identifier: String
    var title: String
    var type: String
    var cdZone: CDZone
    var objectId: String?
    var uuid: String?

    init(identifier: String, title: String, type: String, cdZone: CDZone) {
        self.identifier = identifier
        self.title = title
        self.type = type
        self.cdZone = cdZone
    }
}
