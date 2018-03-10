//
// Created by Binay Budhthoki on 3/10/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

protocol EnergyCost {
    func cost(energyUsed: Double) -> Double
}

class GasCost: EnergyCost {

    lazy var pricing: Dictionary<ERateKey, Double> = {
        let utility = GasRate()
        return utility.getBillData()
    }()

    // *** Gives the Average Cost Per Day *** //
    //ToDo: How do you interpret the slabs for other utitlity companies ??
    func cost(energyUsed: Double) -> Double {

        var slabPricing = 0.0

        if energyUsed <= 5 {
            slabPricing = pricing[ERateKey.slab1]!
        } else if energyUsed <= 16 {
            slabPricing = pricing[ERateKey.slab2]!
        } else if energyUsed <= 41 {
            slabPricing = pricing[ERateKey.slab3]!
        } else if energyUsed <= 123 {
            slabPricing = pricing[ERateKey.slab4]!
        } else {
            slabPricing = pricing[ERateKey.slab5]!
        }

        // Since the values are per day - Dividing by 2 averages Summer | Winter as they are both of 6 months
        slabPricing += (pricing[ERateKey.summerTransport]! + pricing[ERateKey.winterTransport]!) / 2 + pricing[ERateKey.surcharge]!

        return  (slabPricing * energyUsed)
    }
}

class ElectricCost: EnergyCost {
    var rateStructure: String
    var operatingHours: Dictionary<EDay, String>

    lazy var pricing: Dictionary<ERateKey, Double> = {
        let utility = ElectricRate(type: rateStructure)
        return utility.getBillData()
    }()

    lazy var usageByPeak: Dictionary<ERateKey, Double> = {
        let peak = PeakHourMapper()
        return peak.run(usage: operatingHours)
    }()

    lazy var usageByDay: Double = {
        let peak = PeakHourMapper()
        return peak.annualOperatingHours(operatingHours) / 365
    }()

    init(rateStructure: String, operatingHours: Dictionary<EDay, String>) {
        self.rateStructure = rateStructure
        self.operatingHours = operatingHours
    }

    //ToDo: What about cases where is no Time of Use ??
    func cost(energyUsed: Double) -> Double {

        var regex = try! NSRegularExpression(pattern: "^.*tou$")
        let match = regex.matches(in: rateStructure.lowercased(), range: NSRange(location: 0, length: rateStructure.count))
        if (match.count > 0) {
            var summer = Double(usageByPeak[ERateKey.summerOn]!) * energyUsed * pricing[ERateKey.summerOn]!
            summer += Double(usageByPeak[ERateKey.summerPart]!) * energyUsed * pricing[ERateKey.summerPart]!
            summer += Double(usageByPeak[ERateKey.summerOff]!) * energyUsed * pricing[ERateKey.summerOff]!

            var winter = Double(usageByPeak[ERateKey.winterPart]!) * energyUsed * pricing[ERateKey.winterPart]!
            winter += Double(usageByPeak[ERateKey.winterOff]!) * energyUsed * pricing[ERateKey.winterOff]!

            return (summer + winter) / 2
        } else {
            let summer = usageByDay * energyUsed * pricing[ERateKey.summerNone]!
            let winter = usageByDay * energyUsed * pricing[ERateKey.winterNone]!

            return (summer + winter) / 2
        }
    }
}