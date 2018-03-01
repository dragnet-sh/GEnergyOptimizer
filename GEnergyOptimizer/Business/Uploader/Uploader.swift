//
// Created by Binay Budhthoki on 3/1/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

protocol Uploadable {
    func upload(_ filename: String, data: Data, finished: () -> Void)
}

class Uploader {

}
