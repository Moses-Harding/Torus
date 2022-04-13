//
//  Asset Names.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/25/21.
//

import Foundation

public enum BackgroundLabelAsset: String {
    case redHighlighted = "Red Label Background - Highlighted"
    case redUnhighlighted = "Red Label Background"
    case blueHighlighted = "Blue Label Background - Highlighted"
    case blueUnhighlighted = "Blue Label Background"
}

public enum ButtonAssets: String {
    case back = "Back Button"
    case backDisabled = "Back Button - Disabled"
    case endTurn = "End Turn Button"
    case endTurnDisabled = "End Turn Button - Disabled"
    case forfeit = "Forfeit Button"
    case forfeitDisabled = "Forfeit Button - Disabled"
    case rematch = "Rematch Button"
    case start = "Start Button V2"
    case quit = "Quit Button"
}

public enum LabelAssets: String {
    case background = "Background Design V3"
    case defeat = "Defeat Label V2"
    case gameStart = "Game Start Label"
    case logo = "Torus Neon Logo V2"
    case opponentQuit = "Opponent Quit Label"
    case victory = "Victory Label V2"
}

public enum OrbAsset: String, CaseIterable {
    case orb1 = "Orb-1"
    case orb2 = "Orb-2"
    case orb3 = "Orb-3"
    case orb4 = "Orb-4"
    case orb5 = "Orb-5"
    case orb6 = "Orb-6"
}

public enum PowerConsoleAssets: String {
    case normal = "PowerConsole V2"
    case filled = "PowerConsole - Filled"
    case noEffect = "PowerConsole - No Effect"
    case powerConsoleOverHeat = "PowerConsole - OverHeat"
    case opponentTurn = "PowerConsole - Opponent Turn In Progress"
    case onlyPink = "PowerConsole - Can Only Select Pink"
    case onlyBlue = "PowerConsole - Can Only Select Blue"
}

public enum TileAssets: String {
    case l1 = "Tile - L1"
    case l2 = "Tile - L2"
    case l3 = "Tile - L3"
    case l4 = "Tile - L4"
    case l5 = "Tile - L5"
    case selectedTile = "Tile - Selected"
    case attackTile = "Tile - Attack"
    case disintegrateTile = "Tile - Disintegrate"
}

public enum TorusAsset: String {
    case blueBase = "Torus - Blue"
    case bluePoweredUp = "Torus - Blue - Powered Up"
    case blueSelected = "Torus - Blue - Selected"
    case bluePoweredUpSelected = "Torus - Blue - Powered Up - Selected"
    case redBase = "Torus - Red"
    case redPoweredUp = "Torus - Red - Powered Up"
    case redSelected = "Torus - Red - Selected"
    case redPoweredUpSelected = "Torus - Red - Powered Up - Selected"
}

public enum TorusOverlayAssets: String {
    case amplify = "Amplify"
    case armor = "Armor"
    case freeMovement = "Free Movement"
    case snare = "Snare"
    case weightless = "Weightless"
}
