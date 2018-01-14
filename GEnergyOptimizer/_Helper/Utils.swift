//
// Created by Binay Budhthoki on 12/3/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger

class ControllerUtils {
    static func fromStoryboard(reference: String) -> UIViewController {
        return fromStoryboard(reference: reference, vc: reference)
    }

    static func fromStoryboard(reference: String, vc: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: reference, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vc)
        return vc
    }
}


class LoggerUtils {
    static func getConfig() -> [LogConfiguration] {
        var configs = [LogConfiguration]()
        let stderr = StandardStreamsLogRecorder(formatters: [FieldBasedLogFormatter(
                fields: [.timestamp(.custom("MM-dd HH:mm")),
                         .delimiter(.tab), .callSite, .literal(" "), .severity(.xcode),
                         .literal(" "), .payload]
        )])
        configs.append(BasicLogConfiguration(recorders: [stderr]))

        return configs
    }
}

class GUtils {
    static func message(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }

    static func activeStorage() -> EStorage {
        return EStorage.server
    }

    static func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            Log.message(.info, message: url.absoluteString)
        }
    }
}
