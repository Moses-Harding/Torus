//
//  Enums.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/12/21.
//

import Foundation
import SpriteKit

enum DeathType {
    case disintegrate, obliterate, fadeOut, normal, snare
}

enum MoveType {
    case invalid, normal, attack, orb, relocate
}

enum MovePointDirection {
    case left, right, up, down
}

enum SpriteLevel: CGFloat {
    case playScreen = 0, boardOrTray = 1, tileOrTrayItem = 2, torusOrScrollView = 3, tileOverlay = 4, label = 5, userMessage = 6, topLevel = 100
}

enum TorusOverlaySpriteLevel: CGFloat {
    case inhibited = 1
    case moveDiagonal
    case amplify
    case jumpProof
    case weightless
    case snare
}

enum TeamColor {
    case red, blue
}

enum TileHeight: Int, Codable {
    case l1 = -2, l2, l3, l4, l5
}

enum TileStatus: String, Codable {
    case normal, disintegrated, base
}

enum TorusColor: Codable {
    case red, blue, green, orange
}

