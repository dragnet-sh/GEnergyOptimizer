//
//  TestEnergyCalculations.swift
//  
//
//  Created by Binay Budhthoki on 1/5/18.
//

import XCTest
@testable import GEnergyOptimizer

class TestEnergyCalculations: XCTestCase {
    var utility: UtilityMapper!
    
    override func setUp() {
        super.setUp()
        utility = GasRate()
    }

    func testUtilityRate() {
        let tmp = utility.getBillData()
        print(tmp.debugDescription)
    }
}
