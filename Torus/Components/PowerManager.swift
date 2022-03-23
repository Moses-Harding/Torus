//
//  Power.swift
//  Triple Bomb
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
        
        print("Assigning power \(power.name) to \(torus.name)")
        
        let exceeds20 = torus.powerUp(with: power)
        
        if !exceeds20 {
            gameManager.tray.powerList.updateView(with: torus.powers, from: torus, calledBy: "PowerManager Assigning Power")
        }
    }
    
    func removePower(from torus: Torus, _ power: PowerType) {
        
        if TestingManager.helper.verbose { print("Removing \(torus), \(power)") }
        
        guard let powerCount = torus.powers[power] else {
            print("Correct power is not present")
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
        
        var finalClosure = { self.removePower(from: torus, powerType) }
        
        switch powerType.power {
        case .acidic:
            (waitDuration, isEffective) = acid(direction, activatedBy: torus)
        case .bombs:
            let (targetTiles, duration, killedSelf) = bombs(activatedBy: torus)
            if !decoding { ChangeManager.register.bombs(power: PowerType(.bombs), for: torus, targetTiles: targetTiles, waitDuration: waitDuration) }
            if killedSelf { finalClosure = { self.gameManager.powerList.clear() } }
            waitDuration = duration
        case .climbTile:
            climbTile(activatedBy: torus)
        case .destroy:
            (waitDuration, isEffective) = destroy(direction, activatedBy: torus)
        case .doublePowers:
            killedSelf = doublePowers(activatedBy: torus)
            if killedSelf { finalClosure = { self.gameManager.powerList.clear() } }
        case .inhibit:
            isEffective = inhibit(direction, activatedBy: torus)
        case .jumpProof:
            jumpProof(activatedBy: torus)
        case .learn:
            (isEffective, killedSelf) = learn(direction, activatedBy: torus)
            if killedSelf { finalClosure = { self.gameManager.powerList.clear() } }
        case .lowerTile:
            lowerTile(activatedBy: torus)
        case .moveDiagonal:
            moveDiagonal(activatedBy: torus)
        case .pilfer:
            (waitDuration, isEffective, killedSelf) = pilfer(direction, activatedBy: torus)
            if killedSelf { finalClosure = { self.gameManager.powerList.clear() } }
        case .purify:
            (waitDuration, isEffective) = purify(direction, activatedBy: torus)
        case .raiseTile:
            raiseTile(activatedBy: torus)
        case .recruit:
            (waitDuration, isEffective) = recruit(direction, activatedBy: torus)
        case .relocate:
            let foundTile: TilePosition?
            (waitDuration, foundTile, isEffective) = relocate(activedBy: torus)
            if !decoding && isEffective { ChangeManager.register.relocate(torus, targetTile: foundTile!, waitDuration: waitDuration)}
        case .smartBombs:
            let (targetTiles, duration, killedSelf) = bombs(activatedBy: torus, smart: true)
            if !decoding { ChangeManager.register.bombs(power: PowerType(.smartBombs), for: torus, targetTiles: targetTiles, waitDuration: waitDuration) }
            waitDuration = duration
        case .snakeTunnelling:
            let (targetTiles, duration) = snakeTunnelling(activatedBy: torus)
            if !decoding { ChangeManager.register.snakeTunnelling(for: torus, targetTiles: targetTiles, waitDuration: waitDuration) }
            waitDuration = duration
        case .swap:
            (waitDuration, isEffective) = swap(direction, activatedBy: torus)
        case .teach:
            isEffective = teach(direction, activatedBy: torus)
        case .trench:
            waitDuration = trench(direction, activatedBy: torus)
        case .tripwire:
            isEffective = tripwire(direction, activatedBy: torus)
        case .wall:
            waitDuration = wall(direction, activatedBy: torus)
        }
        
        let specialPowers: [Power] = [.bombs, .smartBombs, .snakeTunnelling, .relocate]
        
        if !decoding && !specialPowers.contains(powerType.power) && isEffective {
            ChangeManager.register.activate(power: powerType, for: torus)
        }
        
        return (waitDuration, isEffective, finalClosure)
    }
}

extension PowerManager { //Powers
    
    func acid(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            enemy.currentTile.acid()
            waitDuration += AnimationManager.helper.kill(torus: enemy, deathType: .acidic) {}
        }
        
        return (waitDuration, !enemies.isEmpty)
    }
    
    @discardableResult
    func bombs(activatedBy torus: Torus, smart: Bool = false, existingSet: [TilePosition]? = nil) -> ([TilePosition], Double, Bool) {
        
        var targetTiles = [Tile]()
        var targetTilePositions = [TilePosition]()
        var waitDuration: Double = 0
        var killedSelf: Bool = false
        
        if let tilePositions = existingSet {
            removePower(from: torus, PowerType(.bombs))
            for position in tilePositions {
                guard let tile = gameBoard.getTile(from: position) else { fatalError("PowerManager - Bombs - Tile not retrieved") }
                targetTiles.append(tile)
            }
        } else {
            var randomNumber = Int.random(in: 6 ... 12)
            
            if smart { randomNumber += 6 }
            
            for _ in 0 ... randomNumber {
                targetTiles.append(gameBoard.getRandomTile())
            }
            
            targetTiles.append(torus.currentTile)
        }
        
        
        killedSelf = targetTiles.contains(torus.currentTile)
        
        for tile in targetTiles {
            if smart && tile.occupiedBy != nil && tile.occupiedBy!.team == torus.team {
                waitDuration += 0.2
            } else {
                tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                    AnimationManager.helper.bomb(tile: tile)
                }
                targetTilePositions.append(tile.boardPosition)
                waitDuration += 0.2
            }
        }
        
        return (targetTilePositions, waitDuration, killedSelf)
    }
    
    func climbTile(activatedBy torus: Torus) {
        
        torus.climbTile()
    }
    
    func destroy(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            waitDuration += AnimationManager.helper.kill(torus: enemy, deathType: .destroy) {}
        }
        
        return (waitDuration, !enemies.isEmpty)
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
    
    func jumpProof(activatedBy torus: Torus) {
        
        torus.jumpProof()
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
        
        let tile = torus.currentTile
        tile.lower()
    }
    
    func moveDiagonal(activatedBy torus: Torus) {
        
        torus.moveDiagonal()
    }
    
    func pilfer(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool, Bool) {
        
        var waitDuration: CGFloat = 0
        var overHeat = false
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            overHeat = torus.learn(enemy.powers)
            waitDuration += AnimationManager.helper.pilferPowers(from: enemy)
        }
        
        return (waitDuration, !enemies.isEmpty, overHeat)
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
        
        let tile = torus.currentTile
        tile.raise()
    }
    
    func recruit(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            waitDuration = AnimationManager.helper.recruit(torus: enemy)
        }
        
        return (waitDuration, !enemies.isEmpty)
    }
    
    func relocate(activedBy torus: Torus, existingTile: TilePosition? = nil) -> (CGFloat, TilePosition?, Bool) {
        
        var isEffective = false
        var waitDuration: CGFloat = 0
        
        var tile: Tile?
        let totalTileCount = gameBoard.tiles.count
        var numberOfTries = 0
        
        if let foundTile = existingTile {
            guard let targetTile = gameBoard.getTile(from: foundTile) else {fatalError("PowerManager - Relocate - Tile Not Found")}
            waitDuration = MovementManager.helper.move(torus, to: targetTile, relocating: true) {}
            tile = targetTile
        } else {
            
            gameManager.deselectCurrent()
            
            while tile == nil && numberOfTries < totalTileCount {
                let foundTile = gameBoard.getRandomTile()
                if TestingManager.helper.verbose { print("PowerManager - Relocate - Found Tile - \(foundTile) - Occupied By \(foundTile.occupiedBy) - Number Of Tries \(numberOfTries)") }
                if foundTile.occupiedBy == nil && foundTile.hasOrb == false {
                    tile = foundTile
                    waitDuration = MovementManager.helper.move(torus, to: foundTile, relocating: true) {}
                    isEffective = true
                } else {
                    numberOfTries += 1
                }
            }
        }
        
        return (waitDuration, tile?.boardPosition, isEffective)
    }
    
    func snakeTunnelling(activatedBy torus: Torus, existingSet: [TilePosition]? = nil) -> ([TilePosition], CGFloat) {
        
        self.gameBoard.unhighlightTiles()
        
        let startTile = torus.currentTile
        let randomNumber = Int.random(in: 10 ... 15)
        
        var nextTile = startTile
        var targetTiles = [nextTile]
        var targetTilePositions = [nextTile.boardPosition]
        var waitDuration: CGFloat = 0
        
        if let tilePositions = existingSet {
            for tilePosition in tilePositions {
                guard let nextTile = gameBoard.getTile(from: tilePosition) else { fatalError("PowerManager - SnakeTunnelling - Tile Not Retrieve") }
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
                tile.isValidForMovement(moveType: .attack)
                tile.sprite.run(SKAction.wait(forDuration: 0.75)) {
                    tile.isInvalidForMovement()
                }
                if let torus = tile.snakeTunnel(teamToAvoid: torus.team.teamNumber) {
                    AnimationManager.helper.kill(torus: torus, deathType: .tripwire) {}
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
            waitDuration = AnimationManager.helper.recruit(torus: enemy)
        }
        
        if !enemies.isEmpty {
            for ally in allies {
                waitDuration = AnimationManager.helper.recruit(torus: ally)
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
    
    func trench(_ direction: PowerDirection, activatedBy torus: Torus) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        
        var waitDuration: CGFloat = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.changeHeight(to: .l1)
            }
            waitDuration += 0.025
        }
        
        return waitDuration
    }
    
    func tripwire(_ direction: PowerDirection, activatedBy torus: Torus) -> Bool {
        
        let enemies = getEnemies(for: direction, from: torus)
        for enemy in enemies {
            enemy.tripwired()
        }
        
        return !enemies.isEmpty
    }
    
    func wall(_ direction: PowerDirection, activatedBy torus: Torus) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        
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
    
    func getAllies(for direction: PowerDirection, from torus: Torus) -> [Torus] {
        return getTorii(for: direction, from: torus, enemies: false)
    }
    
    func getEnemies(for direction: PowerDirection, from torus: Torus) -> [Torus] {
        return getTorii(for: direction, from: torus, enemies: true)
    }
    
    func getTorii(for direction: PowerDirection, from torus: Torus, enemies: Bool = true) -> [Torus] {
        
        var validTorii = [Torus]()
        
        let enemyTeam = gameManager.getOtherTeam(from: torus.team)
        
        let allTorii = enemies ? enemyTeam.torii : torus.team.torii
        
        switch direction {
        case .column:
            for eachTorus in allTorii {
                if eachTorus.currentTile.boardPosition.column == torus.currentTile.boardPosition.column {
                    validTorii.append(eachTorus)
                }
            }
        case .radius:
            for eachTorus in allTorii {
                let rowDif = abs(eachTorus.currentTile.boardPosition.row - torus.currentTile.boardPosition.row)
                let colDif = abs(eachTorus.currentTile.boardPosition.column - torus.currentTile.boardPosition.column)
                if (rowDif == 0 || rowDif == 1) && (colDif == 0 || colDif == 1) {
                    validTorii.append(eachTorus)
                }
            }
        case .row:
            for eachTorus in allTorii {
                if eachTorus.currentTile.boardPosition.row == torus.currentTile.boardPosition.row {
                    validTorii.append(eachTorus)
                }
            }
        }
        
        return validTorii
    }
    
    func getTiles(for direction: PowerDirection, from torus: Torus) -> [Tile] {
        
        var validTiles = [Tile]()
        
        let row = torus.currentTile.boardPosition.row
        let column = torus.currentTile.boardPosition.column
        
        switch direction {
        case .column:
            for eachRow in 0 ..< scene.numberOfRows {
                if let tile = gameBoard.getTile(column: column, row: eachRow) {
                    validTiles.append(tile)
                }
            }
        case .radius:
            for eachTile in gameBoard.tiles {
                let rowDif = abs(eachTile.boardPosition.row - torus.currentTile.boardPosition.row)
                let colDif = abs(eachTile.boardPosition.column - torus.currentTile.boardPosition.column)
                if (rowDif == 0 || rowDif == 1) && (colDif == 0 || colDif == 1) {
                    validTiles.append(eachTile)
                }
            }
        case .row:
            for eachCol in 0 ..< scene.numberOfColumns {
                if let tile = gameBoard.getTile(column: eachCol, row: row) {
                    validTiles.append(tile)
                }
            }
        }
        
        return validTiles
    }
}
