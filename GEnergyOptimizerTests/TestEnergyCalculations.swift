//
//  TestEnergyCalculations.swift
//  
//
//  Created by Binay Budhthoki on 1/5/18.
//

import XCTest
@testable import GEnergyOptimizer

class TestEnergyCalculations: XCTestCase {
    var energyCalculation: GEnergyCalculations!
    
    override func setUp() {
        super.setUp()
        energyCalculation = GEnergyCalculations()
    }
    
    func testEnergyCalculation() {
        energyCalculation.test()
    }
}
