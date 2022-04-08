//
//  Power Struct.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/13/21.
//

import Foundation

struct ActivatedAttributes: Codable {
    
    //GOOD
    var hasAmplify = false
    var hasWeightless = false
    var hasArmor = false
    var hasFreeMovement = false
    
    //BAD
    var isSnared = false
}

extension ActivatedAttributes: CustomStringConvertible {
    var description: String {
        var description = ""
        if hasAmplify {
            description += ": Amplified"
        }
        if hasWeightless {
            description += ": Weightless"
        }
        if hasArmor {
            description += ": Armor"
        }
        if hasFreeMovement {
            description += ": Free Movement"
        }
        if isSnared {
            description += ": Snared"
        }

        return description
    }
}
