//
// Created by Binay Budhthoki on 12/16/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Eureka
import CleanroomLogger

class GEFormViewController: FormViewController {

    fileprivate var formModel: GEnergyFormModel!

    open override func viewDidLoad() {
        super.viewDidLoad()

        guard let model = BuilderHelper.decodeJSON(bundleResource: getBundleResource()) else {
            Log.message(.error, message: "JSON Decoding Failed")
            return
        }
        self.formModel = model

        initializeForm()
    }

    //*** This needs to be over-ridden by the base class ***//
    open func getBundleResource() -> String! {
        Log.message(.error, message: "Please override method getBundleResource")
        fatalError("Must be over-ridden")
    }

    public func getFormDTO() -> GEnergyFormModel! {
        return self.formModel
    }
}


//Mark: - House Keeping Methods
extension GEFormViewController {

    fileprivate func initializeForm() {

        //1. Decode the JSON
        //2. Map Sections to Elements
        Log.message(.info, message: "GEForm - Initialization")
        guard let gForm = BuilderHelper.mapSectionIdsToElements(model: formModel!) else {
            Log.error?.message("GEnergy - Form Element is Empty")
            return
        }

        //3. Instantiate the FormBuilder - via passing the form instance
        //4. Go through each of the Section - build the components
        //5. The builder will then Integrate the Components
        //6. The form now should be ready for consumption

        let formBuilder = FormBuilder(form: self.form)

        if let indexSortedSection = BuilderHelper.sortedElementIds(model: formModel!) {
            if let mapIdToName = BuilderHelper.mapSectionIdsToName(model: formModel!) {
                indexSortedSection.forEach { sectionId in
                    //Log.message(.info, message: sectionId.debugDescription)
                    formBuilder.build(section: mapIdToName[sectionId]!, elements: gForm[sectionId]!) //ToDo: Forced Unwrapping !!
                }
            }
        }
    }

}