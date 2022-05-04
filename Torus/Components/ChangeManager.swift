//
//  MoveChanges.swift
//  Torus Neon
//
//  Created by Moses Harding on 3/7/22.
// 

import Foundation
import UIKit
import SpriteKit
import AVFAudio

enum ChangeType: Codable {
    case activatePower
    case addOrb
    case addPower
    case missileStrike
    case move
    case float
    case removePowers
    case respawn
    case shuffle
    case burrow
}


struct ShuffledTileAssignment: Codable {
    var torusName: String
    var tilePosition: TilePosition
}

struct OrbAssignment: Codable  {
    var tile: TilePosition
    var nextPower: PowerType
}

struct Change: Codable  {
    var type: ChangeType
    var torus: String
    
    var newPowers: [PowerType:Int]? = nil
    var tile: TilePosition? = nil
    var orbAssignment: OrbAssignment? = nil
    var powerToActivate: PowerType? = nil
    var shuffleDirection: PowerDirection? = nil
    var shuffledList: [ShuffledTileAssignment]? = nil
    var targeted: Bool? = nil
    var targetTiles: [TilePosition]? = nil
    var waitDuration: CGFloat? = nil
}



class ChangeManager: Codable {
    
    static var register = ChangeManager()
    
    var tileChanges = [OrbAssignment]()
    var changes = [Change]()

    
    //Refresh
    func refresh() {
        changes = []
    }
    
    //Tile Changes
    func populateOrb(on tile: Tile, nextPower: PowerType) {
        let change = Change(type: .addOrb, torus: "", orbAssignment: OrbAssignment(tile: tile.boardPosition, nextPower: nextPower))
        changes.append(change)
    }
    
    func missileStrike(power: PowerType, for torus: Torus, targetTiles: [TilePosition], targeted: Bool, waitDuration: CGFloat) {
        let change = Change(type: .missileStrike, torus: torus.name, targeted: targeted, targetTiles: targetTiles, waitDuration: waitDuration)
        changes.append(change)
    }
    
    func float(_ torus: Torus, targetTile: TilePosition, waitDuration: CGFloat) {
        let change = Change(type: .float, torus: torus.name, tile: targetTile, waitDuration: waitDuration)
        changes.append(change)
    }
    
    func burrow(for torus: Torus, targetTiles: [TilePosition], waitDuration: CGFloat) {
        let change = Change(type: .burrow, torus: torus.name, targetTiles: targetTiles, waitDuration: waitDuration)
        changes.append(change)
    }
    
    func activate(power: PowerType, duration: CGFloat, for torus: Torus) {
        let change = Change(type: .activatePower, torus: torus.name, powerToActivate: power, waitDuration: duration)
        changes.append(change)
    }
    
    func addPower(for torus: Torus) {
        let change = Change(type: .addPower, torus: torus.name, newPowers: torus.powers)
        changes.append(change)
    }
    
    func move(_ torus: Torus, to tile: Tile) {
        let change = Change(type: .move, torus: torus.name, tile: tile.boardPosition)
        changes.append(change)
    }

    func removePowers(for torus: Torus) {
        let change = Change(type: .removePowers, torus: torus.name)
        changes.append(change)
    }
    
    func respawn(_ torus: Torus) {
        let change = Change(type: .respawn, torus: torus.name)
        changes.append(change)
    }
    
    func shuffle(_ tileAssignments: [ShuffledTileAssignment], direction: PowerDirection, for torus: Torus, waitDuration: CGFloat) {
        let change = Change(type: .shuffle, torus: torus.name, shuffleDirection: direction, shuffledList: tileAssignments, waitDuration: waitDuration)
        changes.append(change)
    }
}

class ChangeDecoder {
    
    static var helper = ChangeDecoder()
    
    var gameScene: GameScene?
    
    var currentlyDecoding = false
    
    func decode(_ changes: [Change], completion: (() ->())? = nil) {
        
        guard let scene = gameScene else { fatalError("Change Decoder - GameScene not passed") }
        guard let manager = scene.gameManager else { fatalError("Change Decoder - GameManager not passed") }
        
        var waitDuration: Double = 0
        
        currentlyDecoding = true
        
        scene.run(SKAction.wait(forDuration: 1)) {
            
            for change in changes {
                
                if TestingManager.helper.verboseChanges { print("Change \(change) will activate at \(waitDuration)") }
                
                switch change.type {
                case .activatePower:
                    guard let powerType = change.powerToActivate else { fatalError("Change Decoder - Activate Power - No Power Passed") }
                    guard let duration = change.waitDuration else { fatalError("Change Decoder - Activate Power - No Wait Duration Passed") }
                    
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change) - \(String(describing: change.powerToActivate))") }
                        if TestingManager.helper.verboseChanges { manager.gameBoard.printGameBoard() }
                        PowerManager.helper.activate(powerType, with: torus, decoding: true)
                        
                        let powerLabel = TextNode(powerType.name, size: torus.sprite.size)
                        powerLabel.label.fontSize = 20
                        powerLabel.position = CGPoint(x: -torus.sprite.size.width / 2, y: torus.sprite.size.height / 2)
                        torus.sprite.addChild(powerLabel)
                        powerLabel.run(SKAction.wait(forDuration: 0.5)) {
                            powerLabel.removeFromParent()
                        }
                        
                        manager.updateUI()
                    }
                    
                    waitDuration += duration
                case .addOrb:
                    guard let tile = manager.gameBoard.getTile(from: change.orbAssignment?.tile) else { fatalError("Change Decoder - Add Orb - No Tile Passed") }
                    guard let powerType = change.orbAssignment?.nextPower else { fatalError("Change Decoder - Add Orb - No Power Passed") }
                    
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change) - \(String(describing: change.powerToActivate))") }
                        tile.populateOrb(decoding: true, nextPower: powerType, calledBy: "ChangeDecorder - Add Orb")
                        manager.updateUI()
                    }
                    
                    waitDuration += 0.2
                case .addPower:
                    guard let powers = change.newPowers else { fatalError("Change Decoder - Add Power - No Powers Passed") }
                    
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        torus.powers = [:]
                        for (power, powerCount) in powers {
                            torus.powers[power] = (torus.powers[power] ?? 0) + powerCount
                        }
                        manager.updateUI()
                    }
                    
                    waitDuration += 0.25
                case .missileStrike:
                    guard let targetTiles = change.targetTiles else { fatalError("Change Decoder - MissileStrike - No Target Tiles passed") }
                    guard let duration = change.waitDuration else { fatalError("Change Decoder - MissileStrike - No wait duration passed") }
                    guard let targeted = change.targeted else {  fatalError("Change Decoder - MissileStrike - No Smart MissileStrike Passed") }
                    
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change)") }
                        if TestingManager.helper.verboseChanges { manager.gameBoard.printGameBoard() }
                        
                        PowerManager.helper.removePower(from: torus, targeted ? PowerType(.targetedStrike) : PowerType(.missileStrike))
                        _ = PowerManager.helper.missileStrike(activatedBy: torus, existingSet: targetTiles)
                        
                        
                        let powerLabel = TextNode(targeted ? "Targeted Missile Strike" : "Missile Strike", size: torus.sprite.size)
                        powerLabel.label.fontSize = 20
                        powerLabel.position = CGPoint(x: -torus.sprite.size.width / 2, y: torus.sprite.size.height / 2)
                        torus.sprite.addChild(powerLabel)
                        powerLabel.run(SKAction.wait(forDuration: 0.5)) {
                            powerLabel.removeFromParent()
                        }
                        
                        manager.updateUI()
                    }
                    waitDuration += duration
                case .move:
                    guard let tile = manager.gameBoard.getTile(from: change.tile) else { fatalError("Change Decoder - Move - No destination tile passed")}

                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change)") }
                        if TestingManager.helper.verboseChanges { manager.gameBoard.printGameBoard() }
                        
                        _ = MovementManager.helper.move(torus, to: tile, decoding: true) {}
                        manager.updateUI()
                    }
                    
                    waitDuration += 1
                case .burrow:
                    guard let targetTiles = change.targetTiles else { fatalError("Change Decoder - SnakeTUnneling - No Target Tiles passed") }
                    guard let duration = change.waitDuration else { fatalError("Change Decoder - SnakeTUnneling - No wait duration passed") }
                    
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change)") }
                        if TestingManager.helper.verboseChanges { manager.gameBoard.printGameBoard() }
                        
                        PowerManager.helper.removePower(from: torus, PowerType(.burrow))
                        _ = PowerManager.helper.burrow(activatedBy: torus, existingSet: targetTiles)
                        
                        
                        let powerLabel = TextNode("Burrow", size: torus.sprite.size)
                        powerLabel.label.fontSize = 20
                        powerLabel.position = CGPoint(x: -torus.sprite.size.width / 2, y: torus.sprite.size.height / 2)
                        torus.sprite.addChild(powerLabel)
                        powerLabel.run(SKAction.wait(forDuration: 0.5)) {
                            powerLabel.removeFromParent()
                        }
                        
                        manager.updateUI()
                    }
                    
                    waitDuration += duration
                case .float:
                    guard let targetTile = change.tile else { fatalError("Change Decoder - Float - No Target Tile Passed")}
                    guard let duration = change.waitDuration else { fatalError("Change Decoder - Float - No wait duration passed") }
                    
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change), duration \(duration)") }
                        if TestingManager.helper.verboseChanges { manager.gameBoard.printGameBoard() }
                        
                        PowerManager.helper.removePower(from: torus, PowerType(.float))
                        PowerManager.helper.float(activatedBy: torus, existingTile: targetTile)
                        
                        
                        let powerLabel = TextNode("Float", size: torus.sprite.size)
                        powerLabel.label.fontSize = 20
                        powerLabel.position = CGPoint(x: -torus.sprite.size.width / 2, y: torus.sprite.size.height / 2)
                        torus.sprite.addChild(powerLabel)
                        powerLabel.run(SKAction.wait(forDuration: 0.5)) {
                            powerLabel.removeFromParent()
                        }
                        
                        manager.updateUI()
                    }
                    
                    waitDuration += duration
                case .respawn:
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change)") }
                        
                        PowerManager.helper.respawnOrbs(decoding: true)
                        
                        manager.updateUI()
                    }
                    
                    waitDuration += 0.1
                case .removePowers:
                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        torus.powers = [:]
                        manager.updateUI()
                    }
                    
                    waitDuration += 0.25
                case .shuffle:
                    guard let shuffledList = change.shuffledList else { fatalError("Change Decoder - Shuffle - No Tiles passed") }
                    guard let duration = change.waitDuration else { fatalError("Change Decoder - Shuffle - No wait duration passed") }

                    scene.run(SKAction.wait(forDuration: waitDuration)) {
                        guard let torus = scene.gameManager.getTorus(with: change.torus) else { fatalError("Change Decoder - Torus could not be located") }
                        guard let direction = change.shuffleDirection else { fatalError("Change Decoder - Shuffle - No Scrmable Direction paased") }
                        
                        if TestingManager.helper.verboseChanges { print("\nChange - \(change)") }
                        if TestingManager.helper.verboseChanges { manager.gameBoard.printGameBoard() }
                        
                        PowerManager.helper.removePower(from: torus, PowerType(.shuffle, direction))
                        _ = MovementManager.helper.decodedShuffle(shuffledList: shuffledList)
                        
                        
                        let powerLabel = TextNode("Shuffle", size: torus.sprite.size)
                        powerLabel.label.fontSize = 20
                        powerLabel.position = CGPoint(x: -torus.sprite.size.width / 2, y: torus.sprite.size.height / 2)
                        torus.sprite.addChild(powerLabel)
                        powerLabel.run(SKAction.wait(forDuration: 0.5)) {
                            powerLabel.removeFromParent()
                        }
                        
                        manager.updateUI()
                    }
                    waitDuration += duration + 0.1
                }
                waitDuration += 0.1
            }
            
            scene.run(SKAction.wait(forDuration: waitDuration)) {
                scene.model.savePreTurnData(from: scene)
                scene.gameManager.updateUI()
            }
            
            manager.powerList.displayPowerConsole(message: .processing, duration: waitDuration ,calledBy: "ChangeManager - DecodeChanges")
        
            self.currentlyDecoding = false
        }
    }
}
