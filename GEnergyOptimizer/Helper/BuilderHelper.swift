//
// Created by Binay Budhthoki on 12/16/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger


class BuilderHelper {

    // *** Decoding JSON *** //
    public static func decodeJSON(bundleResource: String) -> GEnergyFormDTO? {
        let url = Bundle.main.url(forResource: bundleResource, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json: AnyObject

        json = try! JSONSerialization.jsonObject(with: data, options: []) as AnyObject
        let dictionary = json as? [String: Any]

        if let dictionary = dictionary {
            return GEnergyFormDTO(json: dictionary)
        }

        Log.message(.error, message: "JSON Serialization Failed")
        return nil
    }

    // *** Mapping Section Ids to GElements *** //
    public static func mapSectionIdsToElements(dto: GEnergyFormDTO) -> Dictionary<String, [GElements]>? {
        return self.Mapper(dto: dto).mapSIdToGElements
    }

    // *** Mapping Section Id to Section Name *** //
    public static func mapSectionIdsToName(dto: GEnergyFormDTO) -> Dictionary<String, String>? {
        return self.Mapper(dto: dto).mapSIdToSName
    }

    // *** Mapping Element Id to GElements *** //
    public static func mapIdToElements(dto: GEnergyFormDTO) -> Dictionary<String, GElements>? {
        return self.Mapper(dto: dto).mapEIdToGElements
    }

    // *** Get Section Id as an Array (Sorted) *** //
    public static func sortedElementIds(dto: GEnergyFormDTO) -> [String]? {
        return self.Sorter(mapIndex: self.Mapper(dto: dto).mapIndexSID).sortedIds
    }

    // *** Get Form Id as an Array (Sorted) *** //
    public static func sortedFormElementIds(dto: GEnergyFormDTO) -> [String]? {
        return self.Sorter(mapIndex: self.Mapper(dto: dto).mapIndexEID).sortedIds
    }
}


//Mark: - Section | Elements Sorter Block

extension BuilderHelper {

    fileprivate class Sorter {
        public var sortedIds: Array<String>
        public var mapIndex: Dictionary<Int, String>

        init(mapIndex: Dictionary<Int, String>) {
            self.mapIndex = mapIndex
            self.sortedIds = Array<String>()

            sortMap()
        }

        fileprivate func sortMap() {
            let sortedKeys = Array(mapIndex.keys).sorted { (indexA: Int, indexB: Int) -> Bool in
                return indexA < indexB
            }

            sortedKeys.forEach { id in
                if let sectionId = mapIndex[id] {
                    sortedIds.append(sectionId)
                }
            }
        }
    }
}


//Mark: - Section | Elements Mapper Block

extension BuilderHelper {

    fileprivate class Mapper {

        public var mapSIdToSName: Dictionary<String, String>
        public var mapSIdToGElements: Dictionary<String, [GElements]>
        public var mapEIdToGElements: Dictionary<String, GElements>

        public var mapIndexSID: Dictionary<Int, String>
        public var mapIndexEID: Dictionary<Int, String>

        public let dto: GEnergyFormDTO

        init(dto: GEnergyFormDTO) {
            self.dto = dto

            self.mapSIdToSName = Dictionary<String, String>()
            self.mapSIdToGElements = Dictionary<String, [GElements]>()
            self.mapEIdToGElements = Dictionary<String, GElements>()

            self.mapIndexSID = Dictionary<Int, String>()
            self.mapIndexEID = Dictionary<Int, String>()

            mapSId()
        }

        fileprivate func mapSId() {

            guard let dtoForm = dto.form else {
                Log.message(.error, message: "Empty DTO Form")
                return
            }

            for block in dtoForm {
                if let sectionId = block.sectionId, let index = block.index, let gElements = block.elements, let sectionName = block.section {
                    self.mapSIdToGElements[sectionId] = gElements
                    self.mapSIdToSName[sectionId] = sectionName
                    self.mapIndexSID[index] = sectionId

                    gElements.forEach { gElements in
                        if let elementId = gElements.elementId, let index = gElements.index {
                            self.mapEIdToGElements[elementId] = gElements
                            self.mapIndexEID[index] = elementId
                        }
                    }
                }
            }
        }
    }
}
