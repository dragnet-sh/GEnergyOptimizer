//
// Created by Binay Budhthoki on 12/3/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import PopupDialog

class ControllerUtils {
    static func fromStoryboard(reference: String) -> UIViewController {
        return fromStoryboard(reference: reference, vc: reference)
    }

    static func fromStoryboard(reference: String, vc: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: reference, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vc)
        return vc
    }

    static func getPopEdit(addAction: @escaping (String)->Void) -> PopupDialog {
        let popEditViewController = PopEditViewController(nibName: "PopEditViewController", bundle: nil)

        popEditViewController.activeHeader = "Add Room"
        popEditViewController.activeEditLine = ""

        let popup = PopupDialog(viewController: popEditViewController, buttonAlignment: .horizontal, gestureDismissal: true)

        let btnCancel = CancelButton(title: "Cancel", height: 40) {
            //1. Discard the changes
        }
        let btnAdd = DefaultButton(title: "Add", height: 40) {
            guard let input = popEditViewController.txtEditField.text?.trimmingCharacters(in: .whitespaces) else {return}
            Log.message(.info, message: "Value: \(input)")
            addAction(input)
        }
        popup.addButtons([btnCancel, btnAdd])

        return popup
    }

    static func getTableEditActions() -> [UITableViewRowAction]{
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
        }

        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (action, indexPath) in
        }

        deleteAction.backgroundColor = UIColor.red
        editAction.backgroundColor = UIColor.green

        return [deleteAction, editAction]
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
