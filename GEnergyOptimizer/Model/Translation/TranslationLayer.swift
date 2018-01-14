//
// Created by Binay Budhthoki on 1/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

// *** Converts Parse Data Objects to Core Data Objects *** //
class TranslationLayer {

    class var sharedInstance: TranslationLayer {
        struct Singleton {
            static let instance = TranslationLayer()
        }
        return Singleton.instance
    }


    public func mapObjectModel() {
        Log.message(.info, message: "Mapping Object Model")
    }
}