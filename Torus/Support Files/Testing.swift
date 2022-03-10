//
//  Testing.swift
//  Triple Bomb
//
//  Created by Moses Harding on 11/28/21.
//

import Foundation
import SpriteKit

class TestingManager {
    
    static let helper = TestingManager()
    
    //Test Powers
    var testPowers = false
    
    var heightList: [PowerType] = [PowerType(.raiseTile), PowerType(.lowerTile), PowerType(.wall, .row), PowerType(.wall, .radius), PowerType(.wall, .column), PowerType(.trench, .radius), PowerType(.trench, .row), PowerType(.trench, .column)]
    
    var powersToTest: [PowerType] = [PowerType(.raiseTile), PowerType(.lowerTile), PowerType(.wall, .row), PowerType(.wall, .radius), PowerType(.wall, .column), PowerType(.trench, .radius), PowerType(.trench, .row), PowerType(.trench, .column)]
    
    //Test Number of orbs
    var testOrbs = false
    var numberOfOrbsToTest = 20
}
