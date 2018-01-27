//
// Created by Binay Budhthoki on 12/3/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import PopupDialog
import Toaster

class ControllerUtils {
    static func fromStoryboard(reference: String) -> UIViewController {
        return fromStoryboard(reference: reference, vc: reference)
    }

    static func fromStoryboard(reference: String, vc: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: reference, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vc)
        return vc
    }

    static func getTableEditActions(delete: @escaping (Int)->Void, edit: @escaping (Int)->Void) -> [UITableViewRowAction]{
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            delete(indexPath.row)
        }

        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
            edit(indexPath.row)
        }

        delete.backgroundColor = UIColor.red
        edit.backgroundColor = UIColor.green

        return [delete, edit]
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
    static func message(title: String, message: String, vc: UIViewController, type: EMessageType) {
        switch type {
        case .toast:
            Toast(text: message).show()

        case .alert:
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }

    static func activeStorage() -> EStorage {
        return EStorage.server
    }

    static func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            Log.message(.info, message: "\(url.absoluteString)Application Support/GEModel.sqlite")
        }
    }

    static func getEZone(rawValue: String) -> EZone {
        if let eVal = EZone(rawValue: rawValue) {
            return eVal
        } else { return .none }
    }

    static func transform(value: String, type: String) -> Any? {
        guard let baseRowType = InitEnumMapper.sharedInstance.enumMap[type] else {
            Log.error?.message("Base Row Type Not Found - \(type)")
            return nil
        }

        switch baseRowType {
            case .intRow: return Int(value)
            case .decimalRow: return NSDecimalNumber(string: value)
            default: return value
        }
    }
}
