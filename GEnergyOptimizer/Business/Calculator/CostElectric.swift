//
// Created by Binay Budhthoki on 2/20/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

typealias EPeakDouble = Dictionary<EPeak, Double>
typealias EPeakInt = Dictionary<EPeak, Int>

class CostElectric: GECalculator, Computable {
    fileprivate let usage: Double
    fileprivate let pricing: EPeakDouble
    fileprivate let hoursByPeak: EPeakInt

    init(usage: Double, pricing: EPeakDouble, hoursByPeak: EPeakInt) {
        self.usage = usage
        self.pricing = pricing
        self.hoursByPeak = hoursByPeak
    }

    func compute() -> Double {
        var summer = Double(hoursByPeak[EPeak.summerOn]!) * usage * Double(pricing[EPeak.summerOn]!)
        summer += Double(hoursByPeak[EPeak.summerPart]!) * usage * Double(pricing[EPeak.summerPart]!)
        summer += Double(hoursByPeak[EPeak.summerOff]!) * usage * Double(pricing[EPeak.summerOff]!)

        var winter = Double(hoursByPeak[EPeak.winterPart]!) * usage * Double(pricing[EPeak.winterPart]!)
        winter += Double(hoursByPeak[EPeak.winterOff]!) * usage * Double(pricing[EPeak.winterOff]!)

        return (summer + winter)
    }
}