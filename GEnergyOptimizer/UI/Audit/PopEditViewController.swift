//
//  PopEditViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/7/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import PopupDialog
import CleanroomLogger

class PopEditViewController: UIViewController {
    @IBOutlet weak var txtEditField: UITextField!
    @IBOutlet weak var lblEditHeader: UILabel!
    
    var activeHeader: String?
    var activeEditLine: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEditField.delegate = self
        lblEditHeader.text = activeHeader!
        txtEditField.text = activeEditLine!

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    @objc func endEditing() {
        view.endEditing(true)
        //self.dismiss(animated: true)
    }
}

extension PopEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Log.message(.info, message: "Text Field Should Return")
        Log.message(.info, message: textField.text.debugDescription)
        endEditing()
        return true
    }
}
