//
//  Power Struct.swift
//  Triple Bomb
//
//  Created by Moses Harding on 10/13/21.
//

import Foundation

struct ActivatedAttributes: Codable {
    
    //GOOD
    var hasAmplify = false
    var hasClimbTile = false
    var hasFlatToSphere = false
    var hasInvisibility = false
    var hasJumpProof = false
    var hasMoveDiagonal = false
    
    //BAD
    var isInhibited = false
    var isSpyTapped = false
    var isTripWired = false
}

extension ActivatedAttributes: CustomStringConvertible {
    var description: String {
        var description = ""
        if hasAmplify {
            description += ": Amplified"
        }
        if hasClimbTile {
            description += ": ClimbTile"
        }
        if hasFlatToSphere {
            description += ": FlatToSphere"
        }
        if hasInvisibility {
            description += ": Invisible"
        }
        if hasJumpProof {
            description += ": JumpProof"
        }
        if hasMoveDiagonal {
            description += ": MoveDiagonal"
        }
        
        if isInhibited {
            description += ": Inhibited"
        }
        if isSpyTapped {
            description += ": SpyTapped"
        }
        if isTripWired {
            description += ": Tripwired"
        }

        return description
    }
}
