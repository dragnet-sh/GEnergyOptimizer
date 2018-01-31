//
// Created by Binay Budhthoki on 1/11/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class RoomDTO {
    var identifier: String
    var title: String
    var guid: String
    var cdRoom: CDRoom

    init(identifier: String, title: String, guid: String, cdRoom: CDRoom) {
        self.identifier = identifier
        self.title = title
        self.guid = guid
        self.cdRoom = cdRoom
    }
}