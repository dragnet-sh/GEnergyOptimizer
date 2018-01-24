//
// Created by Binay Budhthoki on 1/11/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class RoomListDTO {
    var identifier: String
    var title: String
    var guid: String

    init(identifier: String, title: String, guid: String) {
        self.identifier = identifier
        self.title = title
        self.guid = guid
    }
}