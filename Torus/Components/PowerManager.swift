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
        
        print("Assigning power")
        
        let exceeds20 = torus.powerUp(with: power)
        //scene.scrollView.updateView(with: torus.powers, from: torus.team.teamNumber)
        
        if !exceeds20 {
            gameManager.tray.powerList.updateView(with: torus.powers, from: torus, calledBy: "PowerManager Assigning Power")
        }
    }
    
    func removePower(from torus: Torus, _ power: PowerType) {
        
        print("Removing \(torus), \(power)")
        
        guard let powerCount = torus.powers[power] else {
            print("Correct power is not present")
            return
        }
        
        if powerCount == 1 {
            torus.powers.removeValue(forKey: power)
        } else {
            torus.powers[power]! = powerCount - 1
        }
        //scene.scrollView.updateView(with: torus.powers, from: torus.team.teamNumber)
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
        case .raiseTile:
            raiseTile(activatedBy: torus)
        case .smartBombs:
            let (targetTiles, duration, killedSelf) = bombs(activatedBy: torus, smart: true)
            if !decoding { ChangeManager.register.bombs(power: PowerType(.smartBombs), for: torus, targetTiles: targetTiles, waitDuration: waitDuration) }
            waitDuration = duration
        case .snakeTunelling:
            let (targetTiles, duration) = snakeTunnelling(activatedBy: torus)
            waitDuration = duration
        case .teach:
            isEffective = teach(direction, activatedBy: torus)
        case .trench:
            waitDuration = trench(direction, activatedBy: torus)
        case .tripwire:
            isEffective = tripwire(direction, activatedBy: torus)
        case .wall:
            waitDuration = wall(direction, activatedBy: torus)
        }
        
        if !decoding && powerType.power != .bombs && powerType.power != .smartBombs && isEffective {
            ChangeManager.register.activate(power: powerType, for: torus)
        }
        
        return (waitDuration, isEffective, finalClosure)
    }
}

extension PowerManager { //Powers
    
    func acid(_ direction: PowerDirection, activatedBy torus: Torus) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getTorii(for: direction, from: torus)
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
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            waitDuration += AnimationManager.helper.kill(torus: enemy, deathType: .destroy) {}
        }
        
        return (waitDuration, !enemies.isEmpty)
    }
    
    func inhibit(_ direction: PowerDirection, activatedBy torus: Torus) -> Bool {
        
        let enemies = getTorii(for: direction, from: torus)
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
        let allies = getTorii(for: direction, from: torus, enemies: false)
        for ally in allies {
            if ally.name != torus.name {
                overHeat = torus.learn(ally.powers)
            }
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
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            overHeat = torus.learn(enemy.powers)
            waitDuration += AnimationManager.helper.pilferPowers(from: enemy)
        }
        
        return (waitDuration, !enemies.isEmpty, overHeat)
    }
    
    func raiseTile(activatedBy torus: Torus) {
        
        let tile = torus.currentTile
        tile.raise()
    }
    
    func snakeTunnelling(activatedBy torus: Torus, smart: Bool = false, existingSet: [TilePosition]? = nil) -> ([TilePosition], CGFloat) {
        
        self.gameBoard.unhighlightTiles()
        
        let startTile = torus.currentTile
        let randomNumber = Int.random(in: 10 ... 15)
        
        var nextTile = startTile
        var targetTiles = [nextTile]
        var targetTilePositions = [nextTile.boardPosition]
        var waitDuration: CGFloat = 0
        
        for _ in 0 ... randomNumber {
            nextTile = gameBoard.getRandomNeighboringTile(from: nextTile)
            targetTiles.append(nextTile)
            targetTilePositions.append(nextTile.boardPosition)
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
    
    func teach(_ direction: PowerDirection, activatedBy torus: Torus) -> Bool {
        
        let allies = getTorii(for: direction, from: torus, enemies: false)
        
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
        
        let enemies = getTorii(for: direction, from: torus)
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
