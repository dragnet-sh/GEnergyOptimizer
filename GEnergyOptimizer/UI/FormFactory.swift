//
// Created by Binay Budhthoki on 11/27/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Eureka
import CleanroomLogger

//Factory to build form elements
//Each Row element implements IFormFactory
//Input - GElements (This has all the details the Factory needs to create the specified row)
//Returns - BaseRow once the required initialization is being done

protocol IFormFactory {
    func create(gElements: GElements) -> BaseRow
}

//TextRow
struct FactoryTextRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let textRow = TextRow(tag: gElements.elementId)
        textRow.title = gElements.param

        return textRow
    }
}

//TextAreaRow
struct FactoryTextAreaRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let textAreaRow = TextAreaRow(tag: gElements.elementId)
        textAreaRow.title = gElements.param
        textAreaRow.textAreaHeight = .fixed(cellHeight: 80)

        return textAreaRow
    }
}

//EmailRow
struct FactoryEmailRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let emailRow = EmailRow(tag: gElements.elementId)
        emailRow.title = gElements.param

        return emailRow
    }
}

//PhoneRow
struct FactoryPhoneRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let phoneRow = PhoneRow(tag: gElements.elementId)
        phoneRow.title = gElements.param

        return phoneRow
    }
}

//IntRow
struct FactoryIntRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let intRow = IntRow(tag: gElements.elementId)
        intRow.title = gElements.param

        return intRow
    }
}

//DecimalRow
struct FactoryDecimalRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let decimalRow = DecimalRow(tag: gElements.elementId)
        decimalRow.title = gElements.param

        return decimalRow
    }
}

//PickerInputRow
struct FactoryPickerInputRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let pickerInputRow = PickerInputRow<String>(tag: gElements.elementId)
        pickerInputRow.title = gElements.param

        let defaultValues = gElements.defaultValues
        let options = defaultValues!.split(separator: ",")

        for option in options {
            pickerInputRow.options.append(String(option))
        }

        return pickerInputRow
    }
}

//ButtonRow
struct FactoryButtonRow: IFormFactory {
    func create(gElements: GElements) -> BaseRow {
        let buttonRow = ButtonRow(tag: gElements.elementId)
        buttonRow.title = gElements.param

        return buttonRow
    }
}