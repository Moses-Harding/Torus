//
//  Power.swift
//  Torus Neon
//
//  Created by Moses Harding on 9/27/21.
// 

import Foundation
import SpriteKit

class PowerManager {
    
    var scene: GameScene!
    
    static let helper = PowerManager()
    
    var gameBoard: GameBoard {
        return scene.gameManager.gameBoard
    }
    
    var gameManager: GameManager {
        return scene.gameManager
    }
    
    func assign(power: PowerType, to torus: Torus) {
        
        if TestingManager.helper.verbosePowers { print("Assigning power \(power.name) to \(torus.name)") }
        
        let exceeds20 = torus.powerUp(with: power)
        
        if !exceeds20 {
            gameManager.tray.powerList.updateView(with: torus.powers, from: torus, calledBy: "PowerManager Assigning Power")
        }
    }
    
    func removePower(from torus: Torus, _ power: PowerType) {
        
        if TestingManager.helper.verbosePowers { print("Removing \(power.name) from \(torus)") }
        
        guard let powerCount = torus.powers[power] else {
            print("\(torus), on \(torus.currentTile), does not have this power - its power list is \(torus.powers)")
            return
        }
        
        if powerCount == 1 {
            torus.powers.removeValue(forKey: power)
        } else {
            torus.powers[power]! = powerCount - 1
        }
        
        gameManager.tray.powerList.updateView(with: torus.powers, from: torus, calledBy: "PowerManager Removing Power")
    }
    
    @discardableResult
    func activate(_ powerType: PowerType, with torus: Torus, decoding: Bool = false) -> (CGFloat, Bool, (() -> ())) {
        
        let direction = powerType.direction ?? .radius //Radius doesn't matter, just unwrapping.
        
        var waitDuration: CGFloat = 0.1
        var isEffective = true
        var killedSelf = false
        
        var finalClosure: (() -> ())
        
        switch powerType.power {
        case .amplify:
            isEffective = amplify(activatedBy: torus)
        case .disintegrate:
            (waitDuration, isEffective) = disintegrate(direction, activatedBy: torus)
        case .consolidate:
            (waitDuration, isEffective, killedSelf) = pilfer(direction, activatedBy: torus, consolidate: true)
        case .missileStrike:
            let (targetTiles, duration, killed) = missileStrike(activatedBy: torus)
            killedSelf = killed
            if !decoding { ChangeManager.register.missileStrike(power: PowerType(.missileStrike), for: torus, targetTiles: targetTiles, targeted: false, waitDuration: duration) }
            waitDuration = duration
        case .weightless:
            isEffective = weightless(activatedBy: torus)
        case .obliterate:
            (waitDuration, isEffective) = obliterate(direction, activatedBy: torus)
        case .doublePowers:
            killedSelf = doublePowers(activatedBy: torus)
        case .inhibit:
            isEffective = inhibit(direction, activatedBy: torus)
        case .invert:
            waitDuration = invert(direction, activatedBy: torus)
        case .jumpProof:
            isEffective = jumpProof(activatedBy: torus)
        case .kamikaze:
            (waitDuration, isEffective) = obliterate(direction, activatedBy: torus, kamikaze: true)
        case .learn:
            (isEffective, killedSelf) = learn(direction, activatedBy: torus)
        case .lowerTile:
            lowerTile(activatedBy: torus)
        case .moat:
            waitDuration = trench(direction, activatedBy: torus, moat: true)
        case .moveDiagonal:
            isEffective = moveDiagonal(activatedBy: torus)
        case .pilfer:
            (waitDuration, isEffective, killedSelf) = pilfer(direction, activatedBy: torus)
        case .purify:
            (waitDuration, isEffective) = purify(direction, activatedBy: torus)
        case .raiseTile:
            raiseTile(activatedBy: torus)
        case .defect:
            (waitDuration, isEffective) = defect(direction, activatedBy: torus)
        case .relocate:
            let foundTile: TilePosition?
            (waitDuration, foundTile, isEffective) = relocate(activatedBy: torus)
            if !decoding && isEffective { ChangeManager.register.relocate(torus, targetTile: foundTile!, waitDuration: waitDuration)}
        case .respawnOrbs:
            if !decoding { ChangeManager.register.respawn(torus) } //This one is before the function bc it registers the tile changes separately
            respawnOrbs(decoding: false)
        case .scramble:
            waitDuration = scramble(direction, activatedBy: torus)
        case .targetedStrike:
            let (targetTiles, duration, _) = missileStrike(activatedBy: torus, smart: true)
            if !decoding { ChangeManager.register.missileStrike(power: PowerType(.targetedStrike), for: torus, targetTiles: targetTiles, targeted: true, waitDuration: duration) }
            waitDuration = duration
        case .burrow:
            let (targetTiles, duration) = burrow(activatedBy: torus)
            if !decoding { ChangeManager.register.burrow(for: torus, targetTiles: targetTiles, waitDuration: duration) }
            waitDuration = duration
        case .swap:
            (waitDuration, isEffective) = swap(direction, activatedBy: torus)
        case .teach:
            isEffective = teach(direction, activatedBy: torus)
        case .trench:
            waitDuration = trench(direction, activatedBy: torus)
        case .snare:
            isEffective = snare(direction, activatedBy: torus)
        case .wall:
            waitDuration = wall(direction, activatedBy: torus)
        }
        
        if killedSelf {
            finalClosure = { self.gameManager.updateUI() }
        } else {
            finalClosure = {
                self.removePower(from: torus, powerType)
                self.gameManager.updateUI()
            }
        }
        
        let specialPowers: [Power] = [.missileStrike, .targetedStrike, .burrow, .relocate, .respawnOrbs, .scramble]
        
        if !decoding && !specialPowers.contains(powerType.power) && isEffective {
            ChangeManager.register.activate(power: powerType, duration: waitDuration, for: torus)
        }
        
        return (waitDuration, isEffective, finalClosure)
    }
}

extension PowerManager { //Powers
    
    func amplify(activatedBy torus: Torus) -> Bool {
        if torus.activatedAttributes.hasAmplify {
            return false
        } else {
            torus.amplify()
            return true
        }
    }
    
    func disintegrate(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            enemy.currentTile.disintegrate()
            waitDuration = AnimationManager.helper.kill(torus: enemy, deathType: .disintegrate, calledBy: "Disintegrate") {}
        }
        
        return (waitDuration, !enemies.isEmpty)
    }
    
    //@discardableResult
    func missileStrike(activatedBy torus: Torus, smart: Bool = false, existingSet: [TilePosition]? = nil) -> ([TilePosition], CGFloat, Bool) {
        
        var targetTiles = [Tile]()
        var targetTilePositions = [TilePosition]()
        var waitDuration: CGFloat = 0
        var killedSelf: Bool = false
        
        if let tilePositions = existingSet {
            removePower(from: torus, PowerType(.missileStrike))
            for position in tilePositions {
                guard let tile = gameBoard.getTile(from: position) else { fatalError("PowerManager - MissileStrike - Tile not retrieved") }
                targetTiles.append(tile)
            }
        } else {
            var randomNumber = Int.random(in: 6 ... 12)
            
            if smart { randomNumber += 6 }
            
            if torus.activatedAttributes.hasAmplify { randomNumber += 6 }
            
            for _ in 0 ... randomNumber {
                let tile = gameBoard.getRandomTile()
                if tile.status != .disintegrated {
                    targetTiles.append(tile)
                }
            }
            
            targetTiles.append(torus.currentTile)
        }
        
        
        killedSelf = targetTiles.contains(torus.currentTile)
        
        for tile in targetTiles {
            if smart && tile.occupiedBy != nil && tile.occupiedBy!.team == torus.team {
                waitDuration += 0.2
            } else {
                tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                    AnimationManager.helper.missile(tile: tile)
                }
                targetTilePositions.append(tile.boardPosition)
                waitDuration += 0.2
            }
        }
        
        return (targetTilePositions, waitDuration, killedSelf)
    }
    
    func weightless(activatedBy torus: Torus) -> Bool {
        
        if torus.activatedAttributes.hasWeightless {
            return false
        } else {
            torus.weightless()
            return true
        }
    }
    
    func obliterate(_ direction: PowerDirection, activatedBy torus: Torus, kamikaze: Bool = false) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        var torii: [Torus]
        
        if kamikaze {
            torii = getAllTorii(for: direction, from: torus)
        } else {
            torii = getEnemies(for: direction, from: torus)
        }
        
        for eachTorus in torii {
            waitDuration = AnimationManager.helper.kill(torus: eachTorus, deathType: .obliterate, calledBy: "Obliterate") { }
        }
        
        return (waitDuration, !torii.isEmpty)
    }
    
    func doublePowers(activatedBy torus: Torus) -> Bool {
        
        var overHeat = false
        
        var modifiedPowers = torus.powers
        if let count = modifiedPowers[PowerType(.doublePowers)] {
            if count == 1 {
                modifiedPowers[PowerType(.doublePowers)] = nil
            } else {
                modifiedPowers[PowerType(.doublePowers)] = count - 1
            }
        }
        
        overHeat = torus.learn(modifiedPowers)
        
        return overHeat
    }
    
    func inhibit(_ direction: PowerDirection, activatedBy torus: Torus) -> Bool {
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            enemy.inhibited()
        }
        
        return !enemies.isEmpty
    }
    
    func invert(_ direction: PowerDirection, activatedBy torus: Torus) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        gameManager.deselectCurrent()
        
        var waitDuration: CGFloat = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.invert()
            }
            waitDuration += 0.03
        }
        
        return waitDuration
    }
    
    func jumpProof(activatedBy torus: Torus) -> Bool {
        
        if torus.activatedAttributes.hasJumpProof {
            return false
        } else {
            torus.jumpProof()
            return true
        }
    }
    
    func learn(_ direction: PowerDirection, activatedBy torus: Torus) -> (Bool, Bool) {
        
        var overHeat = false
        var waitDuration = 0.1
        let allies = getAllies(for: direction, from: torus)
        for ally in allies where ally.name != torus.name {
            ally.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                ally.select()
                waitDuration += 0.1
                ally.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                    overHeat = torus.learn(ally.powers)
                    ally.deselect()
                }
            }
            
            waitDuration += 0.2
        }
        
        return (!allies.isEmpty, overHeat)
    }
    
    func lowerTile(activatedBy torus: Torus) {
        
        gameManager.deselectCurrent()
        
        let tile = torus.currentTile
        tile.lower()
    }
    
    func moveDiagonal(activatedBy torus: Torus) -> Bool {
        
        gameManager.deselectCurrent()
        
        if torus.activatedAttributes.hasMoveDiagonal {
            return false
        } else {
            torus.moveDiagonal()
            return true
        }
    }
    
    func pilfer(_ direction: PowerDirection, activatedBy torus: Torus, consolidate: Bool = false) -> (CGFloat, Bool, Bool) {
        
        var waitDuration: CGFloat = 0
        var overHeat = false
        
        var torii: [Torus]
        
        if consolidate {
            torii = torus.team.torii
            torii.removeAll { $0.name == torus.name }
        } else {
            torii = getEnemies(for: direction, from: torus)
        }
        
        for eachTorus in torii {
            overHeat = torus.learn(eachTorus.powers)
            waitDuration = AnimationManager.helper.pilferPowers(from: eachTorus)
        }
        
        return (waitDuration, !torii.isEmpty, overHeat)
    }
    
    func purify(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        var wasEffective = false
        
        let enemies = getTorii(for: direction, from: torus, enemies: true)
        let allies = getAllies(for: direction, from: torus)
        
        
        for enemy in enemies {
            let (newDuration, effective) = AnimationManager.helper.purify(enemy, isEnemy: true)
            waitDuration += newDuration
            if effective { wasEffective = true }
        }
        for ally in allies {
            let (newDuration, effective) = AnimationManager.helper.purify(ally, isEnemy: false)
            waitDuration += newDuration
            if effective { wasEffective = true }
        }
        
        return (waitDuration, wasEffective)
    }
    
    func raiseTile(activatedBy torus: Torus) {
        
        gameManager.deselectCurrent()
        
        let tile = torus.currentTile
        tile.raise()
    }
    
    func defect(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            waitDuration = AnimationManager.helper.defect(torus: enemy)
        }
        
        return (waitDuration, !enemies.isEmpty)
    }
    
    func relocate(activatedBy torus: Torus, existingTile: TilePosition? = nil) -> (CGFloat, TilePosition?, Bool) {
        
        var isEffective = false
        var waitDuration: CGFloat = 0
        
        var tile: Tile?
        let totalTileCount = gameBoard.tiles.count
        var numberOfTries = 0
        
        if let foundTile = existingTile {
            guard let targetTile = gameBoard.getTile(from: foundTile) else {fatalError("PowerManager - Relocate - Tile Not Found")}
            waitDuration = MovementManager.helper.move(torus, to: targetTile, relocating: true) { self.gameManager.updateUI() }
            tile = targetTile
        } else {
            
            gameManager.deselectCurrent()
            while tile == nil && numberOfTries < totalTileCount {
                let foundTile = gameBoard.getRandomTile()
                if TestingManager.helper.verbosePowers { print("PowerManager - Relocate - Found Tile - \(foundTile) - Occupied By \(foundTile.occupiedBy) - Number Of Tries \(numberOfTries)") }

                if foundTile.occupiedBy == nil && foundTile.status != .disintegrated {
                    tile = foundTile
                    waitDuration = MovementManager.helper.move(torus, to: foundTile, relocating: true) { self.gameManager.updateUI() }
                    isEffective = true
                } else {
                    numberOfTries += 1
                }
            }
        }
        
        return (waitDuration, tile?.boardPosition, isEffective)
    }
    
    func respawnOrbs(decoding: Bool) {
        
        var respawnCount = 0
        
        for tile in gameBoard.tiles {
            if tile.hasOrb {
                tile.removeOrb {
                    respawnCount += 1
                }
            }
        }
        
        if !decoding { gameManager.generateOrbs(with: respawnCount) }
    }
    
    func scramble(_ direction: PowerDirection, activatedBy torus: Torus) -> CGFloat {
        
        removePower(from: torus, PowerType(.scramble, direction)) //This is here because power doesn't get removed (as torus is killed and re-added)
        
        var waitDuration: CGFloat = 0
        
        var tileList = getTiles(for: direction, from: torus).shuffled()
        var torusList = getAllTorii(for: direction, from: torus)
        
        waitDuration = MovementManager.helper.scramble(torusList, tiles: tileList, direction: direction) { self.gameManager.updateUI() }
        
        return waitDuration
    }
    
    func burrow(activatedBy torus: Torus, existingSet: [TilePosition]? = nil) -> ([TilePosition], CGFloat) {
        
        gameManager.deselectCurrent()
        
        let startTile = torus.currentTile
        var randomNumber = Int.random(in: 10 ... 15)
        if torus.activatedAttributes.hasAmplify { randomNumber += 10 }
        
        var nextTile = startTile
        var targetTiles = [nextTile]
        var targetTilePositions = [nextTile.boardPosition]
        var waitDuration: CGFloat = 0
        
        if let tilePositions = existingSet {
            for tilePosition in tilePositions {
                guard let nextTile = gameBoard.getTile(from: tilePosition) else { fatalError("PowerManager - Burrow - Tile Not Retrieve") }
                targetTiles.append(nextTile)
            }
            targetTilePositions = tilePositions
        } else {
            for _ in 0 ... randomNumber {
                nextTile = gameBoard.getRandomNeighboringTile(from: nextTile)
                targetTiles.append(nextTile)
                targetTilePositions.append(nextTile.boardPosition)
            }
        }
        
        for tile in targetTiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                if let torus = tile.burrow(teamToAvoid: torus.team.teamNumber) {
                    AnimationManager.helper.kill(torus: torus, deathType: .snare, calledBy: "Burrow") {}
                }
            }
            waitDuration += 0.75
        }
        
        return (targetTilePositions, waitDuration)
    }
    
    func swap(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getEnemies(for: direction, from: torus)
        let allies = getAllies(for: direction, from: torus)
        
        for enemy in enemies {
            waitDuration = AnimationManager.helper.defect(torus: enemy)
        }
        
        if !enemies.isEmpty {
            for ally in allies {
                waitDuration = AnimationManager.helper.defect(torus: ally)
            }
        }
        
        return (waitDuration, !enemies.isEmpty)
    }
    
    func teach(_ direction: PowerDirection, activatedBy torus: Torus) -> Bool {
        
        let allies = getAllies(for: direction, from: torus)
        
        var modifiedPowers = torus.powers
        if let count = modifiedPowers[PowerType(.teach, direction)] {
            if count == 1 {
                modifiedPowers[PowerType(.teach, direction)] = nil
            } else {
                modifiedPowers[PowerType(.teach, direction)] = count - 1
            }
        }
        
        for ally in allies {
            if ally.name != torus.name {
                ally.learn(modifiedPowers)
            }
        }
        
        return !allies.isEmpty
    }
    
    func trench(_ direction: PowerDirection, activatedBy torus: Torus, moat: Bool = false) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        
        gameManager.deselectCurrent()
        
        var waitDuration: CGFloat = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                if tile == torus.currentTile && moat {
                    tile.changeHeight(to: .l5)
                } else {
                    tile.changeHeight(to: .l1)
                }
            }
            waitDuration += 0.025
        }
        
        return waitDuration
    }
    
    func snare(_ direction: PowerDirection, activatedBy torus: Torus) -> Bool {
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            enemy.snared()
        }
        
        return !enemies.isEmpty
    }
    
    func wall(_ direction: PowerDirection, activatedBy torus: Torus) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        gameManager.deselectCurrent()
        
        var waitDuration: CGFloat = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.changeHeight(to: .l5)
            }
            waitDuration += 0.03
        }
        
        return waitDuration
    }
    
    func placeHolder(power: PowerType) {
        print("Activate \(power.name)")
    }
}

extension PowerManager { //Selecting Row / Column
    
    func getAllTorii(for direction: PowerDirection, from torus: Torus) -> [Torus] {
        return getTorii(for: direction, from: torus, enemies: false) + getTorii(for: direction, from: torus, enemies: true)
    }
    
    func getAllies(for direction: PowerDirection, from torus: Torus) -> [Torus] {
        return getTorii(for: direction, from: torus, enemies: false)
    }
    
    func getEnemies(for direction: PowerDirection, from torus: Torus) -> [Torus] {
        return getTorii(for: direction, from: torus, enemies: true)
    }
    
    func getTorii(for direction: PowerDirection, from torus: Torus, enemies: Bool = true) -> [Torus] {
        
        var validTorii = [Torus]()
        
        let teamToFind = enemies ? gameManager.getOtherTeam(from: torus.team) : torus.team
        
        let tiles = getTiles(for: direction, from: torus)

        for tile in tiles {
            if let torus = tile.occupiedBy {
                if torus.team == teamToFind {
                    validTorii.append(torus)
                }
            }
        }
        
        return validTorii
    }
    
    func getTiles(for direction: PowerDirection, from torus: Torus) -> [Tile] {
        
        var validTiles = [Tile]()
        
        let amplify = torus.activatedAttributes.hasAmplify
        
        let row = torus.currentTile.boardPosition.row
        let column = torus.currentTile.boardPosition.column
        
        switch direction {
        case .column:
            for eachRow in 0 ..< scene.numberOfRows {
                if let tile = gameBoard.getTile(column: column, row: eachRow) {
                    validTiles.appendIfUnique(tile)
                }
                if amplify {
                    if let tile = gameBoard.getTile(column: column - 1, row: eachRow) {
                        validTiles.appendIfUnique(tile)
                    }
                    if let tile = gameBoard.getTile(column: column + 1, row: eachRow) {
                        validTiles.appendIfUnique(tile)
                    }
                }
            }
        case .radius:
            for eachTile in gameBoard.tiles {
                let rowDif = abs(eachTile.boardPosition.row - torus.currentTile.boardPosition.row)
                let colDif = abs(eachTile.boardPosition.column - torus.currentTile.boardPosition.column)
                if (rowDif == 0 || rowDif == 1) && (colDif == 0 || colDif == 1) {
                    validTiles.appendIfUnique(eachTile)
                }
                if amplify {
                    if (rowDif == 0 || rowDif == 1 || rowDif == 2) && (colDif == 0 || colDif == 1 || colDif == 2) {
                        validTiles.appendIfUnique(eachTile)
                    }
                }
            }
        case .row:
            for eachCol in 0 ..< scene.numberOfColumns {
                if let tile = gameBoard.getTile(column: eachCol, row: row) {
                    validTiles.appendIfUnique(tile)
                }
                if amplify {
                    if let tile = gameBoard.getTile(column: eachCol, row: row - 1) {
                        validTiles.appendIfUnique(tile)
                    }
                    if let tile = gameBoard.getTile(column: eachCol , row: row + 1) {
                        validTiles.appendIfUnique(tile)
                    }
                }
            }
        }
        
        return validTiles
    }
}
