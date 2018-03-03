//
// Created by Binay Budhthoki on 2/13/18.
// Copyright (c) 2018 GeminiEnergyServices. All rights reserved.
//

import Foundation
import CleanroomLogger

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

    public func annualOperatingHours(_ usage: Dictionary<EDay, String>) -> Double {
        var sum = 0.0
        for (day, hourRange) in usage {
            for range in hourRange.split(separator: ",") {
                let time = range.split(separator: " ")
                if time.count < 2 {continue}

                let t1 = String(time[0])
                let t2 = String(time[1])

                if let start = dateFormatter.date(from: t1), let end = dateFormatter.date(from: t2) {
                    if start > end {
                        Log.message(.error, message: "Start Time is Greater that End Time !!")
                        continue
                    }
                    let delta = end.timeIntervalSince1970 - start.timeIntervalSince1970
                    sum += delta
                }
            }
        }

        let weekInYear: Double = 57.142
        let totalSeconds: Double = sum * weekInYear
        let totalHours: Double = totalSeconds / (60 * 60)

        return totalHours
    }

    public func run(usage: Dictionary<EDay, String>) -> Dictionary<ERateKey, Int> {

        for (day, hourRange) in usage {
            for range in hourRange.split(separator: ",") {
                let time = range.split(separator: " ")
                if time.count < 2 {continue}

                let t1 = String(time[0])
                let t2 = String(time[1])

                if let start = dateFormatter.date(from: t1), let end = dateFormatter.date(from: t2) {

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
            }
        }

        if usage.count > 0 {
            ERateKey.getAllElectric.forEach({
                outgoing[$0] = outgoing[$0]! / usage.count
            })
        }

        return outgoing
    }
}