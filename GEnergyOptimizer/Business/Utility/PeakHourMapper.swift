//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation

// *** Note : Every Utility Company can define it's own Peak Hours *** //
class PeakHourMapper {

    let dateFormatter = DateFormatter()
    var outgoing = Dictionary<ERateKey, Int>()

    init() {
        dateFormatter.dateFormat = "HH:mm"
        ERateKey.getAllElectric.map { outgoing[$0] = 0 }
    }

    fileprivate func getTime(time: String) -> Date {
        return dateFormatter.date(from: time)!
    }

    fileprivate func inBetween(now: Date, start: Date, end: Date) -> Bool {
        let a = now.timeIntervalSince1970
        let b = start.timeIntervalSince1970
        let c = end.timeIntervalSince1970

        return (a >= b && a < c) ? true : false
    }

    fileprivate func isSummerPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "12:00"), end: getTime(time: "18:00"))
    }

    fileprivate func isSummerPartialPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "8:30"), end: getTime(time: "12:00")) ||
                inBetween(now: now, start: getTime(time: "18:00"), end: getTime(time: "21:30"))
    }

    fileprivate func isSummerOffPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "21:30"), end: getTime(time: "23:59")) ||
                inBetween(now: now, start: getTime(time: "00:00"), end: getTime(time: "8:30"))
    }

    fileprivate func isWinterPartialPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "8:30"), end: getTime(time: "9:30"))
    }

    fileprivate func isWinterOffPeak(now: Date) -> Bool {
        return inBetween(now: now, start: getTime(time: "21:00"), end: getTime(time: "23:59")) ||
                inBetween(now: now, start: getTime(time: "00:00"), end: getTime(time: "8:30"))
    }

    public func run(usage: String) -> Dictionary<ERateKey, Int> {

        let usageSplit = usage.split(separator: ",")

        usageSplit.map {
            let timeRange = $0.split(separator: " ")
            let start = dateFormatter.date(from: String(timeRange[0]))!
            let end = dateFormatter.date(from: String(timeRange[1]))!
            let delta = 1

            let calendar = Calendar.autoupdatingCurrent
            var step = DateComponents()
            step.minute = delta

            var _date = start
            while _date < end {

                if isSummerOffPeak(now: _date) {outgoing[ERateKey.summerOff]! += delta}
                if isSummerPartialPeak(now: _date) {outgoing[ERateKey.summerPart]! += delta}
                if isSummerPeak(now: _date) {outgoing[ERateKey.summerOn]! += delta}

                if isWinterOffPeak(now: _date) {outgoing[ERateKey.winterOff]! += delta}
                if isWinterPartialPeak(now: _date) {outgoing[ERateKey.winterPart]! += delta}

                _date = calendar.date(byAdding: step, to: _date)!
            }
        }

        return outgoing
    }
}