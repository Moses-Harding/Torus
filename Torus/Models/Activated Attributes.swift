//
//  Power Struct.swift
//  Triple Bomb
//
//  Created by Moses Harding on 10/13/21.
//

import Foundation

struct ActivatedAttributes: Codable {
    
    var hasMoveDiagonal = false
    var hasClimbTile = false
    var hasJumpProof = false
    var hasInvisibility = false
    var hasFlatToSphere = false
    
    var isInhibited = false
    var isTripWired = false
    var isSpyTapped = false
}

extension ActivatedAttributes: CustomStringConvertible {
    var description: String {
        var description = ""
        if hasMoveDiagonal {
            description += "MoveDiagonal; "
        }
        if hasClimbTile {
            description += "ClimbTile; "
        }
        if hasJumpProof {
            description += "JumpProof; "
        }
        if hasInvisibility {
            description += "Invisible; "
        }
        if hasFlatToSphere {
            description += "FlatToSphere; "
        }
        if isInhibited {
            description += "Inhibited; "
        }
        if isTripWired {
            description += "Tripwired; "
        }
        if isSpyTapped {
            description += "SpyTapped"
        }
        return description
    }
}
