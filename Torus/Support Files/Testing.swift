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

    var verboseTiles = false
    var verboseChanges = false
    var verbosePowers = false
    var verbosePowerList = false
    var verboseTouch = false
    
    //Test Powers
    var testPowers = false
    var toriiStartWithPowers = false
    var toriiStartWithStatuses = false
    var testShuffling = false
    
    //Start without gamecetner
    var startWithoutGameCenter = false
    
    var heightList: [PowerType] = [PowerType(.raise), PowerType(.lower), PowerType(.elevate, .row), PowerType(.elevate, .radius), PowerType(.elevate, .column), PowerType(.sink, .radius), PowerType(.sink, .row), PowerType(.sink, .column)]

    var powersToTest: [PowerType] = [PowerType(.weightless), PowerType(.armor), PowerType(.freeMovement), PowerType(.burrow)]
    
    //Test Number of orbs
    var testOrbs = false
    var numberOfOrbsToTest = 20
}
