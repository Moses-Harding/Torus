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
