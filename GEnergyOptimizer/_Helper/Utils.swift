//
// Created by Binay Budhthoki on 12/3/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import Toaster
import CSwiftV

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
    static func message(msg: String) {
        message(title: "N/A", msg: msg, vc: nil, type: .toast)
    }

    static func message(title: String, msg: String, vc: UIViewController? = nil, type: EMessageType) {
        switch type {
        case .toast:
            Toast(text: msg).show()

        case .alert:
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            vc?.present(alert, animated: true, completion: nil)
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

    static func getEAppliance(rawValue: String) -> EApplianceType {
        if let eVal = EApplianceType(rawValue: rawValue) {
            return eVal
        } else { return .none }
    }

    static func getEPeak(rawValue: String) -> EPeak {
        if let eVal = EPeak(rawValue: rawValue) {
            return eVal
        } else { return .none}
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

    static func openCSV(filename: String) -> Array<Dictionary<String, String>>! {
        let url = Bundle.main.url(forResource: filename, withExtension: "csv")!
        let data = try! String(contentsOf: url)
        let csv = CSwiftV(with: data)

        return csv.keyedRows!
    }

    static func toString(subject: Any) -> String {
        return String(describing: subject).trimmingCharacters(in: .whitespaces)
    }
}
