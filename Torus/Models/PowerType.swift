//
//  PowerType.swift
//  Torus Neon
//
//  Created by Moses Harding on 11/29/21.
// 

import Foundation
import SpriteKit

/*
 Ideas for new powers
 - Ram
 - Freeze
 - Leap
 */

enum Power: String, CaseIterable, Codable {
    case amplify = "Amplify"
    case armor = "Armor"
    case burrow = "Burrow"
    case cleanse = "Cleanse"
    case consolidate = "Consolidate"
    case defect = "Defect"
    case disintegrate = "Disintegrate"
    case doublePowers = "Double Powers"
    case elevate = "Elevate"
    case exchange = "Exchange"
    case float = "Float"
    case freeMovement = "Free Movement"
    case invert = "Invert"
    case learn = "Learn"
    case leech = "Leech"
    case lower = "Lower"
    case missileStrike = "Missile Strike"
    case moat = "Moat"
    case obliterate = "Obliterate"
    case raise = "Raise"
    case respawnOrbs = "Respawn Orbs"
    case selfDestruct = "Self Destruct"
    case shuffle = "Shuffle"
    case sink = "Sink"
    case snare = "Snare"
    case targetedStrike = "Targeted Strike"
    case teach = "Teach"
    case weightless = "Weightless"
}

enum PowerDirection: String, CaseIterable, Codable {
    case column = "Column"
    case radius = "Radius"
    case row = "Row"
}

struct PowerType: Hashable, Codable {
    
    var power: Power
    var direction: PowerDirection?
    
    var name: String {
        
        if let direction = direction {
            return "\(self.power.rawValue) \(direction.rawValue)"
        } else {
            return "\(self.power.rawValue)"
        }
    }
    
    init(_ power: Power, _ direction: PowerDirection? = nil) {
        
        self.power = power
        
        let exceptions: [Power] = [.amplify, .consolidate, .missileStrike, .weightless, .doublePowers, .armor, .lower, .freeMovement, .raise, .float, .respawnOrbs, .burrow, .targetedStrike]
        
        self.direction = exceptions.contains(where: { $0 == power }) ? nil : direction
    }
    
    static func random() -> PowerType {
        let randomPower = Power.allCases.randomElement()!
        let randomDirection = PowerDirection.allCases.randomElement()!
        
        return PowerType(randomPower, randomDirection)
    }
}
