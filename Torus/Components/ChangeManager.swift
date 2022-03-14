//
//  MoveChanges.swift
//  Torus
//
//  Created by Moses Harding on 3/7/22.
//

import Foundation
import UIKit
import SpriteKit

enum TorusChangeType: Codable {
    case move
    case activatePower
    //case addPower
    case addPower
    case removePowers
}

enum TileChangeType: Codable  {
    case addOrb
}

struct TorusChange: Codable  {
    var type: TorusChangeType
    var torus: String
    
    var newPowers: [PowerType:Int]? = nil
    var moveToTile: TilePosition? = nil
    var powerToActivate: PowerType? = nil
}

struct TileChange: Codable  {
    var type: TileChangeType
    var tile: TilePosition
}

class ChangeManager: Codable {
    
    static var register = ChangeManager()
    
    var tileChanges = [TileChange]()
    var torusChanges = [TorusChange]()
    
    //Refresh
    func refresh() {
        print("Refreshing change list")
        tileChanges = []
        torusChanges = []
    }
    
    //Tile Changes
    func populateOrb(on tile: Tile) {
        let change = TileChange(type: .addOrb, tile: tile.boardPosition)
        tileChanges.append(change)
    }
    
    //Torus Changes
    func activate(power: PowerType, for torus: Torus) {
        let change = TorusChange(type: .activatePower, torus: torus.name, moveToTile: nil, powerToActivate: power)
        torusChanges.append(change)
    }
    
    func move(_ torus: Torus, to tile: Tile) {
        let change = TorusChange(type: .move, torus: torus.name, moveToTile: tile.boardPosition)
        torusChanges.append(change)
    }
    
    func addPower(for torus: Torus) {
        let change = TorusChange(type: .addPower, torus: torus.name, newPowers: torus.powers)
        torusChanges.append(change)
    }
    
    func removePowers(for torus: Torus) {
        let change = TorusChange(type: .removePowers, torus: torus.name)
        torusChanges.append(change)
    }
}

class ChangeDecoder {
    
    static var helper = ChangeDecoder()
    
    var gameScene: GameScene?
    
    var currentlyDecoding = false
    
    func decode(tileChanges: [TileChange]) {
        
        print("\nDecoding Tile Changes")
        
        guard let scene = gameScene else { fatalError("Change Decoder - GameScene not passed") }
        guard let manager = scene.gameManager else { fatalError("Change Decoder - GameManager not passed") }
        
        currentlyDecoding = true
        
        for tileChange in tileChanges {
            guard let tile = manager.gameBoard.getTile(from: tileChange.tile) else { fatalError("Change Decoder - Tile could not be located") }
            
            print(tileChange)
            
            switch tileChange.type {
            case .addOrb:
                tile.populateOrb(decoding: true)
            }
        }
        
        currentlyDecoding = false
    }
    
    func decode(torusChanges: [TorusChange]) {
        
        print("\nDecoding Torus Changes")
        
        guard let scene = gameScene else { fatalError("Change Decoder - GameScene not passed") }
        guard let manager = scene.gameManager else { fatalError("Change Decoder - GameManager not passed") }
        
        var waitDuration: Double = 0
        
        currentlyDecoding = true
        
        scene.run(SKAction.wait(forDuration: 1)) {
            
            for torusChange in torusChanges {
                guard let torus = scene.gameManager.getTorus(with: torusChange.torus) else { fatalError("Change Decoder - Torus could not be located") }
                
                
                switch torusChange.type {
                case .addPower:

                    guard let powers = torusChange.newPowers else { fatalError("Change Decoder - Add Power - No Powers Passed") }
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        
                        torus.powers = [:]
                        for (power, powerCount) in powers {
                            torus.powers[power] = (torus.powers[power] ?? 0) + powerCount
                        }
                    }
                case .removePowers:
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        torus.powers = [:]
                    }
                case .activatePower:
                    guard let powerType = torusChange.powerToActivate else { fatalError("Change Decoder - Activate Power - No Power Passed") }
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        PowerManager.helper.activate(powerType, with: torus, decoding: true) {}
                    }
                    
                    waitDuration += 1
                case .move:
                    guard let tile = manager.gameBoard.getTile(from: torusChange.moveToTile) else { fatalError("Change Decoder - Move - No destination tile passed")}
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        MovementManager.helper.move(torus, to: tile, decoding: true) {}
                    }
                    
                    waitDuration += 1
                }
            }
            
            self.currentlyDecoding = false
        }
        
    }
}
