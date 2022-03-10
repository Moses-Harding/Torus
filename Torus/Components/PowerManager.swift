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
    
    func assignPower(to torus: Torus) {
        
        guard let power = TestingManager.helper.testPowers ? TestingManager.helper.powersToTest.randomElement() : PowerType.random() else { fatalError("No power retrieved to assing to torus") }
        
        torus.powerUp(with: power)
        scene.scrollView.updateView(with: torus.powers)
    }
    
    func removePower(from torus: Torus, _ power: PowerType) {
        
        let powerCount = torus.powers[power]!
        
        if powerCount == 1 {
            torus.powers.removeValue(forKey: power)
        } else {
            torus.powers[power]! = powerCount - 1
        }
        scene.scrollView.updateView(with: torus.powers)
    }
    
    func activate(_ powerType: PowerType, with torus: Torus, decoding: Bool = false, completion: @escaping () -> ()) {
        removePower(from: torus, powerType)

        let direction = powerType.direction ?? .radius //Radius doesn't matter, just unwrapping. 
        
        switch powerType.power {
        case .acidic:
            acid(direction, activatedBy: torus, completion: completion)
        case .destroy:
            destroy(direction, activatedBy: torus, completion: completion)
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
            pilfer(direction, activatedBy: torus, completion: completion)
        case .raiseTile:
            raiseTile(activatedBy: torus, completion: completion)
        case .teach:
            teach(direction, activatedBy: torus, completion: completion)
        case .trench:
            trench(direction, activatedBy: torus, completion: completion)
        case .tripwire:
            tripwire(direction, activatedBy: torus, completion: completion)
        case .wall:
            wall(direction, activatedBy: torus, completion: completion)
        }
        
        if !decoding {
            ChangeManager.register.activate(power: powerType, for: torus)
            //ChangeManager.register.syncPowers(for: torus)
        }
    }
}

extension PowerManager { //Powers
    
    func acid(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            enemy.currentTile.acid()
            AnimationManager.helper.kill(torus: enemy, deathType: .acidic, completion: completion)
        }
        
        completion()
    }
    
    func destroy(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            AnimationManager.helper.kill(torus: enemy, deathType: .destroy, completion: completion)
        }
        
        completion()
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
    
    func pilfer(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            torus.learn(enemy.powers)
            AnimationManager.helper.pilferPowers(from: enemy)
        }
        
        completion()
    }
    
    func raiseTile(activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let tile = torus.currentTile
        tile.raise()
        
        gameManager.select(torus)
        gameManager.updateLabels()
    }
    
    func teach(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let allies = getTorii(for: direction, from: torus, enemies: false)
        for ally in allies {
            ally.learn(torus.powers)
        }
        
        completion()
    }
    
    func trench(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let tiles = getTiles(for: direction, from: torus)
        
        var waitDuration: Double = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.changeHeight(to: .l1)
            }
            waitDuration += 0.025
        }
        
        gameManager.select(torus)
        gameManager.updateLabels()
    }
    
    func tripwire(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let enemies = getTorii(for: direction, from: torus)
        for enemy in enemies {
            enemy.tripwired()
        }
        
        completion()
    }
    
    func wall(_ direction: PowerDirection, activatedBy torus: Torus, completion: @escaping () -> ()) {
        
        let tiles = getTiles(for: direction, from: torus)
        
        var waitDuration: Double = 0
        for tile in tiles {
            tile.sprite.run(SKAction.wait(forDuration: waitDuration)) {
                tile.changeHeight(to: .l5)
            }
            waitDuration += 0.03
        }
        
        gameManager.select(torus)
        gameManager.updateLabels()
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
