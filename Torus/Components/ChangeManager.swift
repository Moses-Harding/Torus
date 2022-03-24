//
//  MoveChanges.swift
//  Torus
//
//  Created by Moses Harding on 3/7/22.
//

import Foundation
import UIKit
import SpriteKit
import AVFAudio

enum TorusChangeType: Codable {
    case activatePower
    case addPower
    case bombs
    case move
    case relocate
    case removePowers
    case snakeTunnelling
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
    var targetTiles: [TilePosition]? = nil
    var waitDuration: CGFloat? = nil
}

struct TileChange: Codable  {
    var type: TileChangeType
    var tile: TilePosition
    
    var nextPower: PowerType
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
    func populateOrb(on tile: Tile, nextPower: PowerType) {
        let change = TileChange(type: .addOrb, tile: tile.boardPosition, nextPower: nextPower)
        tileChanges.append(change)
    }
    
    func bombs(power: PowerType, for torus: Torus, targetTiles: [TilePosition], waitDuration: CGFloat) {
        let change = TorusChange(type: .bombs, torus: torus.name, targetTiles: targetTiles, waitDuration: waitDuration)
        torusChanges.append(change)
    }
    
    func relocate(_ torus: Torus, targetTile: TilePosition, waitDuration: CGFloat) {
        let change = TorusChange(type: .relocate, torus: torus.name, moveToTile: targetTile, waitDuration: waitDuration)
        torusChanges.append(change)
    }
    
    func snakeTunnelling(for torus: Torus, targetTiles: [TilePosition], waitDuration: CGFloat) {
        let change = TorusChange(type: .snakeTunnelling, torus: torus.name, targetTiles: targetTiles, waitDuration: waitDuration)
        torusChanges.append(change)
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
        
        //print("\nDecoding Tile Changes")
        
        guard let scene = gameScene else { fatalError("Change Decoder - GameScene not passed") }
        guard let manager = scene.gameManager else { fatalError("Change Decoder - GameManager not passed") }
        
        currentlyDecoding = true
        
        for tileChange in tileChanges {
            guard let tile = manager.gameBoard.getTile(from: tileChange.tile) else { fatalError("Change Decoder - Tile could not be located") }
            
            //print(tileChange)
            
            switch tileChange.type {
            case .addOrb:
                tile.populateOrb(decoding: true, nextPower: tileChange.nextPower)
            }
        }
        
        currentlyDecoding = false
    }
    
    func decode(torusChanges: [TorusChange]) {
        
        //print("\nDecoding Torus Changes")
        
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
                case .bombs:
                    guard let targetTiles = torusChange.targetTiles else { fatalError("Change Decoder - Bombs - No Target Tiles passed") }
                    guard let duration = torusChange.waitDuration else { fatalError("Change Decoder - Bomb - No wait duration passed") }
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        PowerManager.helper.bombs(activatedBy: torus, existingSet: targetTiles)
                    }
                    waitDuration += duration
                case .snakeTunnelling:
                    guard let targetTiles = torusChange.targetTiles else { fatalError("Change Decoder - SnakeTUnneling - No Target Tiles passed") }
                    guard let duration = torusChange.waitDuration else { fatalError("Change Decoder - SnakeTUnneling - No wait duration passed") }
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        PowerManager.helper.snakeTunnelling(activatedBy: torus, existingSet: targetTiles)
                    }
                    waitDuration += duration
                case .relocate:
                    guard let targetTile = torusChange.moveToTile else { fatalError("Change Decoder - Relocate - No Target Tile Passed")}
                    guard let duration = torusChange.waitDuration else { fatalError("Change Decoder - Relocate - No wait duration passed") }
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        PowerManager.helper.relocate(activatedBy: torus, existingTile: targetTile)
                    }
                    waitDuration += duration
                case .removePowers:
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        torus.powers = [:]
                    }
                case .activatePower:
                    guard let powerType = torusChange.powerToActivate else { fatalError("Change Decoder - Activate Power - No Power Passed") }
                    
                    torus.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                        PowerManager.helper.activate(powerType, with: torus, decoding: true)
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
