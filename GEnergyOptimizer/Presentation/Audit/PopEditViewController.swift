//
//  PopEditViewController.swift
//  GEnergyOptimizer
//
//  Created by Binay Budhthoki on 12/7/17.
//  Copyright © 2017 GeminiEnergyServices. All rights reserved.
//

import UIKit
import CleanroomLogger
import Presentr

class PopEditViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var txtEditField: UITextField!
    @IBOutlet weak var lblEditHeader: UILabel!
    
    @IBOutlet weak var aeuaeu: UIPickerView!
    var activeHeader: String?
    var activeEditLine: String?

    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerDataSource = ["White", "Red", "Green", "Blue"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEditField.delegate = self
        lblEditHeader.text = activeHeader!
        txtEditField.text = activeEditLine!
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
               
    }
    
    @IBAction func didSelectDone(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
}



extension PopEditViewController: PresentrDelegate {
    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        Log.message(.info, message: "Dismissing View Controller")
        return !keyboardShowing
    }
}

extension PopEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEditField.resignFirstResponder()
        return true
    }
}
