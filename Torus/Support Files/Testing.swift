//
//  Testing.swift
//  Torus Neon
//
//  Created by Moses Harding on 11/28/21.
//

import Foundation
import SpriteKit

class TestingManager {
    
    static let helper = TestingManager()
    
    //
    var verbose = false
    
    var verboseTiles = false
    var verboseChanges = true
    var verbosePowers = false
    var verbosePowerList = true
    var verboseTouch = false
    
    //Test Powers
    var testPowers = false
    var toriiStartWithPowers = true
    
    var toriiStartWithStatuses = false
    
    //Start without gamecetner
    var startWithoutGameCenter = false
    
    var heightList: [PowerType] = [PowerType(.raiseTile), PowerType(.lowerTile), PowerType(.wall, .row), PowerType(.wall, .radius), PowerType(.wall, .column), PowerType(.trench, .radius), PowerType(.trench, .row), PowerType(.trench, .column)]

    var powersToTest: [PowerType] = [PowerType(.weightless), PowerType(.jumpProof), PowerType(.moveDiagonal), PowerType(.burrow)]
    
    //Test Number of orbs
    var testOrbs = false
    var numberOfOrbsToTest = 20
}
