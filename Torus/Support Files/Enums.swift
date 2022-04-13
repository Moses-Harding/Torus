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
    case invalid, normal, attack, orb, float
}

enum MovePointDirection {
    case left, right, up, down
}

enum ScaleDirection {
    case width, height
}

enum SpriteLevel: CGFloat {
    case playScreen = 0, boardOrTray = 1, tileOrTrayItem = 2, torusOrScrollView = 3, tileOverlay = 4, label = 5, userMessage = 80, topLevel = 100
}

enum TestTapType {
    case logo, background
}

enum TorusOverlaySpriteLevel: CGFloat {
    case freeMovement = 1
    case amplify
    case armor
    case weightless
    case snare
}

enum TileHeight: Int, Codable {
    case l1 = -2, l2, l3, l4, l5
}

enum TileStatus: String, Codable {
    case normal, disintegrated, base
}

enum TorusColor: Codable {
    case red, blue
}

