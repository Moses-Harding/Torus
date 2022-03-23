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
    
    //
    var verbose = true
    
    //Test Powers
    var testPowers = false
    var toriiStartWithPowers = false
    
    var heightList: [PowerType] = [PowerType(.raiseTile), PowerType(.lowerTile), PowerType(.wall, .row), PowerType(.wall, .radius), PowerType(.wall, .column), PowerType(.trench, .radius), PowerType(.trench, .row), PowerType(.trench, .column)]
    
    //var powersToTest: [PowerType] = [PowerType(.raiseTile), PowerType(.lowerTile), PowerType(.wall, .row), PowerType(.wall, .radius), PowerType(.wall, .column), PowerType(.trench, .radius), PowerType(.trench, .row), PowerType(.trench, .column), PowerType(.climbTile)]
    //var powersToTest: [PowerType] = [PowerType(.bombs), PowerType(.smartBombs)]
    var powersToTest: [PowerType] = [PowerType(.climbTile), PowerType(.jumpProof), PowerType(.moveDiagonal), PowerType(.snakeTunnelling)]
    
    //Test Number of orbs
    var testOrbs = false
    var numberOfOrbsToTest = 20
}
