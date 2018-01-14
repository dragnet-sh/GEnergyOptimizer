//
// Created by Binay Budhthoki on 1/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

// *** Data Table Object - Home List View Controller *** //
public class HomeListDTO {
    var auditZone: String?
    var count: String?

    init(auditZone: String, count: String) {
        self.auditZone = auditZone
        self.count = count
    }
}