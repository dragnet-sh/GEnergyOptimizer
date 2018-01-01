//
// Created by Binay Budhthoki on 11/24/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import Gloss
import CleanroomLogger

public struct GEnergyFormDTO: JSONDecodable {
    public let form: [GFormBlock]?

    public init?(json: JSON) {
        self.form = "gemini-form" <~~ json
    }
}

public struct GFormBlock: JSONDecodable {
    public let index: Int?
    public let sectionId: String?
    public let section: String?
    public let elements: [GElements]?

    public init?(json: JSON) {
        self.index = "index" <~~ json
        self.sectionId = "id" <~~ json
        self.section = "section" <~~ json
        self.elements = "elements" <~~ json
    }
}

public struct GElements: JSONDecodable {
    public let index: Int?
    public let elementId: String?
    public let param: String?
    public let dataType: String?
    public let defaultValues: String?
    public let validation: String?

    public init?(json: JSON) {
        self.index = "index" <~~ json
        self.elementId = "id" <~~ json
        self.param = "param" <~~ json
        self.dataType = "data-type" <~~ json
        self.defaultValues = "default-values" <~~ json
        self.validation = "validation" <~~ json
    }
}
