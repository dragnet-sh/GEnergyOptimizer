//
// Created by Binay Budhthoki on 12/4/17.
// Copyright (c) 2017 GeminiEnergyServices. All rights reserved.
//

import Foundation

//PreAudit Data
public func getPAData() -> Dictionary<String, Dictionary<String, String>> {
    let pa_data = [
        "auditor info": [
            "name": "Binay Budhathoki",
            "email": "binay.b@gmail.com",
            "phone number": "9841760774"
        ],
        "operation hours": [
            "operation hours per day": "5",
            "number of vacation days": "15"
        ]
    ]

    return pa_data
}

//Feature Data (Zone Plugload - Kitchen Space)
//public func getFeatureData_plugload() -> FeatureDataDTO {
//
//    var featureData = FeatureDataDTO()
//    featureData.data = [
//        [
//            "product name": "oven (microwave)",
//            "product id": "",
//            "year": "",
//            "make": "LG",
//            "model": "MH6842B / 00",
//            "code": "MH6842B.CBKPNPL",
//            "brand": "LG Electronics",
//            "manufacturer": "",
//            "power max": "1450W",
//            "power min": "900W",
//            "sno": "610TAPEDL016",
//
//            //USAGE INFO
//            "usage per week": "daily",
//            "usage hours per day": "5"
//        ],
//        [
//            "product name": "standard size dishwasher",
//            "product id": "",
//            "year": "",
//            "make": "",
//            "model": "8W18D0WE",
//            "brand": "AVANTI",
//            "manufacturer": "",
//
//            //USAGE INFO
//            "usage per week": "daily",
//            "usage hours per day": "3"
//        ],
//        [
//            "product name": "glass door freezer cabinet",
//            "product id": "",
//            "year": "",
//            "make number": "FZS-2D/W",
//            "model name": "FZS-2D/W",
//            "brand": "ADCRAFT",
//            "manufacturer": "Admiral Craft Equipment Corp.",
//
//            //USAGE INFO
//            "usage per week": "daily",
//            "usage hours per day": "24"
//        ],
//        [
//            "product name": "television",
//            "product id": "",
//            "year": "",
//            "make": "",
//            "model name": "55ME345V/F7 A",
//            "model number": "55ME345V/F7 A",
//            "brand": "Magnavox",
//            "manufacturer": "Funai Corporation",
//        ]
//    ]
//
//    return featureData
//}
//
//
////Feature Data (Zone HVAC - Kitchen | Dining | Hallway)
//public func getFeatureData_hvac() -> FeatureDataDTO {
//
//    var featureData = FeatureDataDTO()
//    featureData.data = [
//        [
//            "appliance": "Air-Cooled unitary air-conditioning heat pumps",
//            "cooling capacity": "< 65000",
//            "system type": "Split System",
//            "heat pumps": "10.6 EER3"
//        ],
//        [
//            "appliance": "Air Conditioners, Air Cooled (Cooling Mode)",
//            "size category": "< 65000 Btu/h",
//            "sub category": "Split System",
//            "cee tier 1": "14.0 SEER 12.0 EER",
//            "cee tier 2": "15.0 SEER 12.5 EER"
//        ]
//    ]
//
//    return featureData
//}
//
////Feature Data (Zone Lighting - Kitchen | Dining | Hallway)
//public func getFeatureData_lighting() -> FeatureDataDTO {
//
//    var featureData = FeatureDataDTO()
//    featureData.data = [
//        [
//            "space type": "Public Space with Dark Surrounding",
//            "measured lux": "1200",
//            "area": "1000",
//            "units": "sq feet",
//            "model number": "led 339",
//            "num_lamps": "3",
//            "test hours": "8",
//            "hours on": "5",
//            "watts": "15"
//        ],
//        [
//            "space type": "Working spaces where visual tasks are only occasionally performed",
//            "measured lux": "2000",
//            "area": "2300",
//            "units": "sq feet",
//            "model number": "philips OD201",
//            "num_lamps": "12",
//            "test hours": "6",
//            "hours on": "5",
//            "watts": "20"
//        ]
//    ]
//
//    return featureData
//}
