//
//  Asset Names.swift
//  Triple Bomb
//
//  Created by Moses Harding on 10/25/21.
//

import Foundation

public enum BackgroundLabelAsset: String {
    case redHighlighted = "Red Label Background - Highlighted"
    case redUnhighlighted = "Red Label Background - Unhighlighted"
    case blueHighlighted = "Blue Label Background - Highlighted"
    case blueUnhighlighted = "Blue Label Background - Unhighlighted"
}

public enum TorusAsset: String {
    case redBase = "Torus - Red"
    case redPoweredUp = "Torus - Red - Powered Up"
    case redSelected = "Torus - Red - Selected"
    case redPoweredUpSelected = "Torus - Red - Powered Up - Selected"
    case blueBase = "Torus - Blue"
    case bluePoweredUp = "Torus - Blue - Powered Up"
    case blueSelected = "Torus - Blue - Selected"
    case bluePoweredUpSelected = "Torus - Blue - Powered Up - Selected"
}

public enum OrbAsset: String, CaseIterable {
    case orb1 = "Orb-1"
    case orb2 = "Orb-2"
    case orb3 = "Orb-3"
    case orb4 = "Orb-4"
    case orb5 = "Orb-5"
    case orb6 = "Orb-6"
}

public enum TraySpriteAssets: String {
    case redTextBox = "Text Box - Red"
    case blueTextBox = "Text Box - Blue"
}

public enum TorusOverlayAssets: String {
    case tripwireRed = "Tripwire - Red"
    case tripwireBlue = "Tripwire - Blue"
    case moveDiagonal = "Move Diagonal"
    case jumpProof = "Jump Proof"
    case inhibited = "Inhibited"
}

public enum TileAssets: String {
    case l1 = "Tile - L1"
    case l2 = "Tile - L2"
    case l3 = "Tile - L3"
    case l4 = "Tile - L4"
    case l5 = "Tile - L5"
    case selectedTile = "Tile - Selected"
    case attackTile = "Tile - Attack"
    case acidTile = "Tile - Acid"
}
