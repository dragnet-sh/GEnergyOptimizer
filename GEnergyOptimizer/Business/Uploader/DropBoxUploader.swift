//
// Created by Binay Budhthoki on 3/1/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger
import SwiftyDropbox

class DropBoxUploader: Uploader, Uploadable {
    func upload(_ filename: String = "\(GUtils.fileByTime()).csv", data: Data, finished: () -> Void) {
        if let location = Settings.auditDataSaveLocation as? NSString {
            var path = location.appendingPathComponent(GUtils.folderByDate()) as NSString
            path = path.appendingPathComponent(filename) as NSString

            guard let client = DropboxClientsManager.authorizedClient else {
                Log.message(.error, message: "Un-Authorized")
                return
            }

            client.files.upload(path: path as String, input: data).response { type, error in
                Log.message(.warning, message: type.debugDescription)
                Log.message(.warning, message: error.debugDescription)
            }
        }
    }
}