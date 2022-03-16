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
        
        torus.powerUp(with: power)
        //scene.scrollView.updateView(with: torus.powers, from: torus.team.teamNumber)
        gameManager.tray.powerList.updateView(with: torus.powers, from: torus.team.teamNumber)
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
        gameManager.tray.powerList.updateView(with: torus.powers, from: torus.team.teamNumber)
    }
    
    @discardableResult
    func activate(_ powerType: PowerType, with torus: Torus, decoding: Bool = false, completion: @escaping () -> ()) -> (CGFloat, (() -> ())) {
        
        let direction = powerType.direction ?? .radius //Radius doesn't matter, just unwrapping.
        
        var waitDuration: CGFloat = 0
        
        switch powerType.power {
        case .acidic:
            waitDuration = acid(direction, activatedBy: torus, completion: completion)
        case .bombs:
            let (targetTiles, duration) = bombs(activatedBy: torus, completion: completion)
            if !decoding { ChangeManager.register.bombs(power: PowerType(.bombs), for: torus, targetTiles: targetTiles, waitDuration: waitDuration) }
            waitDuration = duration
        case .climbTile:
            climbTile(activatedBy: torus, completion: completion)
        case .destroy:
            waitDuration = destroy(direction, activatedBy: torus, completion: completion)
        case .inhibit:
            inhibit(direction, activatedBy: torus, completion: completion)
        case .jumpProof:
            jumpProof(activatedBy: torus, completion: completion)
        case .learn:
            learn(direction, activatedBy: torus, completion: completion)
        case .lowerTile:
            lowerTile(activatedBy: torus, completion: completion)
        case .moveDiagonal:
            moveDiagonal(activatedBy: torus, completion: completion)
        case .pilfer:
            waitDuration = pilfer(direction, activatedBy: torus, completion: completion)
        case .raiseTile:
            raiseTile(activatedBy: torus, completion: completion)
        case .smartBombs:
            let (targetTiles, waitDuration) = bombs(activatedBy: torus, smart: true, completion: completion)
            if !decoding { ChangeManager.register.bombs(power: PowerType(.smartBombs), for: torus, targetTiles: targetTiles, waitDuration: waitDuration) }
        case .snakeTunelling:
            let (targetTiles, duration) = snakeTunnelling(activatedBy: torus, completion: completion)
            waitDuration = duration
        case .teach:
            teach(direction, activatedBy: torus, completion: completion)
        case .trench:
            waitDuration = trench(direction, activatedBy: torus, completion: completion)
        case .tripwire:
            tripwire(direction, activatedBy: torus, completion: completion)
        case .wall:
            waitDuration = wall(direction, activatedBy: torus, completion: completion)
        }
        
        if !decoding && powerType.power != .bombs && powerType.power != .smartBombs {
            ChangeManager.register.activate(power: powerType, for: torus)
        }
        
        let finalClosure = { self.removePower(from: torus, powerType) }
        
        return (waitDuration, finalClosure)
    }
}

extension PowerManager { //Powers
    
    func acid(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) -> CGFloat {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            enemy.currentTile.acid()
            waitDuration += AnimationManager.helper.kill(torus: enemy, deathType: .acidic, completion: completion)
        }
        
        completion()
        
        return waitDuration
    }
    
    @discardableResult
    func bombs(activatedBy torus: Torus, smart: Bool = false, existingSet: [TilePosition]? = nil, completion: @escaping () -> ()) -> ([TilePosition], Double) {
        
        var targetTiles = [Tile]()
        var targetTilePositions = [TilePosition]()
        var waitDuration: Double = 0
        
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
        }
        
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
        
        completion()
        
        return (targetTilePositions, waitDuration)
    }
    
    func climbTile(activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        torus.climbTile()
        completion()
    }
    
    func destroy(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) -> CGFloat {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            waitDuration += AnimationManager.helper.kill(torus: enemy, deathType: .destroy, completion: completion)
        }
        
        completion()
        
        return waitDuration
    }
    
    func inhibit(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            enemy.inhibited()
        }
        
        completion()
    }
    
    func jumpProof(activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        torus.jumpProof()
        completion()
    }
    
    func learn(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let allies = getTorii(for: direction, from: torus, enemies: false)
        for ally in allies {
            torus.learn(ally.powers)
        }
        
        completion()
    }
    
    func lowerTile(activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let tile = torus.currentTile
        tile.lower()
        
        gameManager.select(torus)
        gameManager.updateLabels()
    }
    
    func moveDiagonal(activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        torus.moveDiagonal()
        completion()
    }
    
    func pilfer(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) -> CGFloat {
        
        var waitDuration: CGFloat = 0
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            torus.learn(enemy.powers)
            waitDuration += AnimationManager.helper.pilferPowers(from: enemy)
        }
        
        completion()
        
        return waitDuration
    }
    
    func raiseTile(activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let tile = torus.currentTile
        tile.raise()
        
        gameManager.select(torus)
        gameManager.updateLabels()
    }
    
    func snakeTunnelling(activatedBy torus: Torus, smart: Bool = false, existingSet: [TilePosition]? = nil, completion: @escaping () -> ()) -> ([TilePosition], CGFloat) {
        
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
                tile.snakeTunnel(teamToAvoid: torus.team.teamNumber)
                tile.sprite.run(SKAction.wait(forDuration: 0.75)) {
                    tile.isInvalidForMovement()
                }
            }
            waitDuration += 0.75
        }
        
        completion()
        
        return (targetTilePositions, waitDuration)
    }
    
    func teach(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let allies = getTorii(for: direction, from: torus, enemies: false)
        for ally in allies {
            ally.learn(torus.powers)
        }
        
        completion()
    }
    
    func trench(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        
        var waitDuration: CGFloat = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.changeHeight(to: .l1)
            }
            waitDuration += 0.025
        }
        
        gameManager.select(torus)
        gameManager.updateLabels()
        
        return waitDuration
    }
    
    func tripwire(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            enemy.tripwired()
        }
        
        completion()
    }
    
    func wall(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) -> CGFloat {
        
        let tiles = getTiles(for: direction, from: torus)
        
        var waitDuration: CGFloat = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.changeHeight(to: .l5)
            }
            waitDuration += 0.03
        }
        
        gameManager.select(torus)
        gameManager.updateLabels()
        
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
