//
// Created by Binay Budhthoki on 11/27/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation


//INITIALIZE - ENUM Mapper
//Singleton Class

class InitEnumMapper {
    static let sharedInstance = InitEnumMapper()
    var enumMap: Dictionary<String, BaseRowType>

    fileprivate init() {
        //1. Initializing the Map
        self.enumMap = Dictionary<String, BaseRowType>()

        //2. Populating the Map
        self.enumMap["textrow"] = BaseRowType.textRow
        self.enumMap["textarearow"] = BaseRowType.textAreaRow
        self.enumMap["emailrow"] = BaseRowType.emailRow
        self.enumMap["introw"] = BaseRowType.intRow
        self.enumMap["decimalrow"] = BaseRowType.decimalRow
        self.enumMap["phonerow"] = BaseRowType.phoneRow
        self.enumMap["pickerinputrow"] = BaseRowType.pickerInputRow
        self.enumMap["buttonrow"] = BaseRowType.buttonRow

    }
}

//ENUM BaseRow Type

enum BaseRowType: String {
    case textRow, phoneRow, emailRow, textAreaRow
    case intRow, decimalRow, pickerInputRow
    case buttonRow
}

//ENUM - Switch

enum FactoryHelper {
    static func instantiate(type: BaseRowType) -> IFormFactory {
        switch type {
        case .textRow: return FactoryTextRow()
        case .textAreaRow: return FactoryTextAreaRow()
        case .emailRow: return FactoryEmailRow()
        case .intRow: return FactoryIntRow()
        case .decimalRow: return FactoryDecimalRow()
        case .phoneRow: return FactoryPhoneRow()
        case .pickerInputRow: return FactoryPickerInputRow()
        case .buttonRow: return FactoryButtonRow()
        }
    }
}