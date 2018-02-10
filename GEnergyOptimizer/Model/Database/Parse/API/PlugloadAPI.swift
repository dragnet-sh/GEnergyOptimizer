//
// Created by Binay Budhthoki on 2/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

class PlugloadAPI {

    class var sharedInstance: PlugloadAPI {
        struct Singleton {
            static let instance = PlugloadAPI()
        }
        return Singleton.instance
    }


    func getAllMatch() {

    }
}