//
//  TestEnergyCalculations.swift
//  
//
//  Created by Binay Budhthoki on 1/5/18.
//

import XCTest
@testable import GEnergyOptimizer

class TestEnergyCalculations: XCTestCase {
    var usage_1: Dictionary<EDay, String>!
    var usage_2: Dictionary<EDay, String>!
    var usage_3: Dictionary<EDay, String>!
    var peakHourMapper: PeakHourMapper!

    override func setUp() {
        super.setUp()

        usage_1 = [
            EDay.mon: "8:30 12:30"
        ]

        usage_2 = [
            EDay.mon: "8:30 12:30, 14:50 20:00",
            EDay.tue: "12:00 1:00, 8:00 12:30",
            EDay.fri: "7:30 11:40"
        ]

        peakHourMapper = PeakHourMapper()
    }

    func testOperatingHours() {
        print("### Testing - Operating Hours")
        let oph_1 = OperationHours(usage_1)
        XCTAssertTrue(oph_1.weekly() == 4)
        XCTAssertTrue(_round(oph_1.daily()) == 0.57)
        XCTAssertTrue(_round(oph_1.yearly()) == 228.57)

        let oph_2 = OperationHours(usage_2)
        XCTAssertTrue(_round(oph_2.weekly()) == 17.83)
        print(_round(oph_2.daily()) == 2.55)
        print(_round(oph_2.yearly()) == 1019.03)
    }

    func testPeakHourMapper() {
        print("### Testing - Peak Hour Mapper")
        let result_1 = peakHourMapper.run(usage: usage_1)
        XCTAssertTrue(_round(result_1[.winterPart]!) == 240) // 240
        XCTAssertTrue(_round(result_1[.winterOff]!) == 0) // 0
        XCTAssertTrue(_round(result_1[.summerOn]!) == 30) // 30
        XCTAssertTrue(_round(result_1[.summerPart]!) == 210) // 210
        XCTAssertTrue(_round(result_1[.summerOff]!) == 0) // 0
        print(result_1.description)


        let result_2 = peakHourMapper.run(usage: usage_2)
        XCTAssertTrue(_round(result_2[.winterPart]!) == 326.67) // 980
        XCTAssertTrue(_round(result_2[.winterOff]!) == 30) // 90
        XCTAssertTrue(_round(result_2[.summerOn]!) == 83.33) // 250
        XCTAssertTrue(_round(result_2[.summerPart]!) == 243.33) // 730
        XCTAssertTrue(_round(result_2[.summerOff]!) == 30) // 90
        print(result_2.description)
    }

    func _round(_ double: Double) -> Double {
        return round(double * 100) / 100.0
    }
}
