//
//  PowerType.swift
//  Triple Bomb
//
//  Created by Moses Harding on 11/29/21.
//

import Foundation
import SpriteKit

/*Remaing Power Types
 
 Basic Powers
 - Grow Quadradius
 - Create Base

 Maybe Powers
 - Invisibility
 - Spy Tapped
 - Move Again
 - Flat To Sphere
 
 New Powers
 - Ram
 - Freeze
 - Leap
 */

enum Power: String, CaseIterable, Codable {
    case acidic = "Acidic"
    case bombs = "Bombs"
    case climbTile = "Climb Tile"
    case destroy = "Destroy"
    case doublePowers = "Double Powers"
    case inhibit = "Inhibit"
    case jumpProof = "Jump Proof"
    case learn = "Learn"
    case lowerTile = "Lower Tile"
    case moveDiagonal = "Move Diagonal"
    case pilfer = "Pilfer"
    case purify = "Purify"
    case raiseTile = "Raise Tile"
    case recruit = "Recruit"
    case relocate = "Relocate"
    case smartBombs = "Smart Bombs"
    case snakeTunnelling = "Snake Tunnelling"
    case swap = "Swap"
    case teach = "Teach"
    case trench = "Trench"
    case tripwire = "Tripwire"
    case wall = "Wall"
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
        
        let exceptions: [Power] = [.bombs, .climbTile, .doublePowers, .jumpProof, .lowerTile, .moveDiagonal, .raiseTile, .relocate, .snakeTunnelling, .smartBombs]
        
        self.direction = exceptions.contains(where: { $0 == power }) ? nil : direction
    }
    
    static func random() -> PowerType {
        let randomPower = Power.allCases.randomElement()!
        let randomDirection = PowerDirection.allCases.randomElement()!
        
        return PowerType(randomPower, randomDirection)
    }
}
