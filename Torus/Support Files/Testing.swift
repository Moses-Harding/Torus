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

    var verboseTiles = true
    var verboseChanges = true
    var verbosePowers = true
    var verbosePowerList = true
    var verboseTouch = true
    
    //Test Powers
    var testPowers = false
    var toriiStartWithPowers = false
    var toriiStartWithStatuses = false
    var testShuffling = false
    
    //Test Team Size
    var testRows: Int? = nil
    var testCols: Int? = nil
    
    //Start without gamecetner
    var startWithoutGameCenter = false
    
    var heightList: [PowerType] = [PowerType(.raise), PowerType(.lower), PowerType(.elevate, .row), PowerType(.elevate, .radius), PowerType(.elevate, .column), PowerType(.sink, .radius), PowerType(.sink, .row), PowerType(.sink, .column)]

    var powersToTest: [PowerType] = [PowerType(.weightless), PowerType(.armor), PowerType(.freeMovement), PowerType(.burrow)]
    
    //Test Number of orbs
    var testOrbs = false
    var numberOfOrbsToTest = 20
}
