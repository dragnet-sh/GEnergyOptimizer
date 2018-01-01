//
// Created by Binay Budhthoki on 11/27/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Eureka
import CleanroomLogger


//This builder gets the JSON data
//Uses the FormFactory to instantiate all the required objects
//Builds the From - Integrates the components via the integrate method

class FormBuilder {

    let form: FormViewControllor

    public init(form: FormViewControllor) {
        self.form = form
    }

    public func build(section: String, elements: [GElements]) {

        var collectRows = [BaseRow]()
        for item in elements {

            //1. Extract the Element Data Type
            guard let dataType = item.dataType else {
                Log.error?.message("Data Type Missing - Section \(section)")
                return
            }

            //2. Covert the String Element Data Type to Specific BaseRowType
            guard let baseRowType = InitEnumMapper.sharedInstance.enumMap[dataType] else {
                Log.error?.message("Base Row Type Not Found - \(dataType)")
                return
            }

            //3. Factory instantiates the Specific BaseRowType
            let factory = FactoryHelper.instantiate(type: baseRowType)
            let row = factory.create(gElements: item)
            collectRows.append(row)
        }

        //4. Integrating - Section with Row
        self.form.append(integrate(section: section, rows: collectRows))
    }

    public func integrate(section: String, rows: [BaseRow]) -> Section {
        let section = Section(section)
        for row in rows {
            section.append(row)
        }
        return section
    }
}
