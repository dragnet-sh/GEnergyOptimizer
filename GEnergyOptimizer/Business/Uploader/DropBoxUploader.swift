//
// Created by Binay Budhthoki on 3/1/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import SwiftyDropbox

class DropBoxUploader: Uploader, Uploadable {
    func upload(path: String, data: Data, finished: @escaping () -> Void) {
        guard let client = DropboxClientsManager.authorizedClient else {
            Log.message(.error, message: "Un-Authorized")
            return
        }

        client.files.upload(path: path, mode: .overwrite, autorename: false, clientModified: nil, mute: false, propertyGroups: nil, input: data).response { type, error in
            Log.message(.warning, message: type.debugDescription)
            Log.message(.warning, message: error.debugDescription)
            finished()
        }
    }
}