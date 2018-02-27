//
//  TestEnergyCalculations.swift
//  
//
//  Created by Binay Budhthoki on 1/5/18.
//

import XCTest
@testable import GEnergyOptimizer

class TestEnergyCalculations: XCTestCase {
    var energy: GEnergy!
    
    override func setUp() {
        super.setUp()
        energy = GEnergy()
    }

    func testUtilityRate() {
        energy.calculate()
    }
}
