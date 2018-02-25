//
//  TestEnergyCalculations.swift
//  
//
//  Created by Binay Budhthoki on 1/5/18.
//

import XCTest
@testable import GEnergyOptimizer

class TestEnergyCalculations: XCTestCase {
    var utility: GasCost!
    
    override func setUp() {
        super.setUp()
        utility = GasCost()
    }

    func testUtilityRate() {
        let tmp = utility.cost(energyUsed: 30)
        print(tmp.debugDescription)
    }
}
