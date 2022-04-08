//
//  MovementManager.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/13/21.
//

import Foundation
import SpriteKit

class MovementManager {
    
    var scene: GameScene!
    
    static let helper = MovementManager()
    
    func movement(from torus: Torus, to tile: Tile) -> MoveType {
        
        if !heightIsValid(from: torus, to: tile) || !statusIsValid(for: tile) || !destinationIsValid(from: torus, to: tile) {
            return .invalid
        } else {
            return moveType(for: torus, to: tile)
        }
    }
    
    private func destinationIsValid(from torus: Torus, to new: Tile) -> Bool {
        
        let current = torus.currentTile
        
        let rowSum = new.boardPosition.row - current.boardPosition.row
        let colSum = new.boardPosition.column - current.boardPosition.column
        
        return (torus.activatedAttributes.hasFreeMovement && abs(colSum) == 1 && abs(rowSum) == 1 ) || abs(colSum + rowSum) == 1
    }
    
    private func heightIsValid(from torus: Torus, to tile: Tile) -> Bool {
        
        return torus.activatedAttributes.hasWeightless || (torus.currentTile.height.rawValue - tile.height.rawValue >= -1)
    }
    
    private func moveType(for torus: Torus, to tile: Tile) -> MoveType {
        
        guard let occupant = tile.occupiedBy else { return tile.hasOrb ? .orb : .normal }
        
        return occupant.team == torus.team || occupant.activatedAttributes.hasArmor ? .invalid : .attack
    }
    
    private func statusIsValid(for tile: Tile) -> Bool {
        
        return tile.status == .disintegrated ? false : true
    }
}

extension MovementManager {
    
    func getValidMoves(for torus: Torus) -> [(tile: Tile, moveType: MoveType)] {
        
        var validMoves = [(tile: Tile, moveType: MoveType)]()
        
        for row in -1 ... 1 {
            for col in -1 ... 1 {
                if let tile = scene.gameManager.gameBoard.getTile(column: torus.currentTile.boardPosition.column + col, row: torus.currentTile.boardPosition.row + row) {
                    let move = movement(from: torus, to: tile)
                    if move != .invalid {
                        validMoves.append((tile: tile, moveType: move))
                    }
                }
            }
        }
        
        return validMoves
    }
}

extension MovementManager { //Torus Movement
    
    func decodedShuffle(shuffledList: [ShuffledTileAssignment]) -> CGFloat {
        
        var tileAssignments = [(Torus, Tile)]()
        
        var waitDuration: CGFloat = 0.5
        let fadeDuration: CGFloat = 0.5
        
        shuffledList.forEach {
            guard let torus = scene.gameManager.getTorus(with: $0.torusName) else { fatalError("MovementManager - decodedShuffle - Torus \($0.torusName) could not be located") }
            torus.sprite.run(SKAction.group([SKAction.fadeOut(withDuration: fadeDuration), SKAction.scale(to: 1.2, duration: fadeDuration)]))
        }
        
        scene.run(SKAction.wait(forDuration: fadeDuration)) {
            for eachPair in shuffledList {
                guard let torus = self.scene.gameManager.getTorus(with: eachPair.torusName) else { fatalError("MovementManager - decodedShuffle - Torus \(eachPair.torusName) could not be located") }
                guard let tile = self.scene.gameManager.gameBoard.getTile(from: eachPair.tilePosition) else { fatalError("MovementManager - decodedShuffle - Tile \(eachPair.tilePosition) could not be located") }
                tileAssignments.append((torus, tile))
                tile.occupiedBy = nil
                torus.die(calledBy: "Decoded Shuffle")
            }
            
            for tileAssignment in tileAssignments {
                waitDuration = AnimationManager.helper.shuffle(torus: tileAssignment.0, to: tileAssignment.1, takeOrb: tileAssignment.1.hasOrb)
            }
        }
        
        return waitDuration + fadeDuration
    }
    
    func shuffle(_ torii: [Torus], tiles: [Tile], direction: PowerDirection, decoding: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        var torusList = torii
        var tileList = tiles
        
        var waitDuration: CGFloat = 0.5
        let fadeDuration: CGFloat = 0.5
        
        var tileAssignments = [(Torus, Tile)]()
        var shuffledTileAssignmentsForDecoding = [ShuffledTileAssignment]()
        
        torusList.forEach {
            $0.sprite.run(SKAction.group([SKAction.fadeOut(withDuration: fadeDuration), SKAction.scale(to: 1.2, duration: fadeDuration)]))
        }
        
        guard let firstTorus = torusList.first else { fatalError("MovementManager - Shuffle - No First Torus Found")  }
        
        firstTorus.sprite.run(SKAction.wait(forDuration: fadeDuration)) {
            while torusList.count > 0 && tileList.count > 0 {
                guard let tile = tileList.popLast() else { fatalError("MovementManager - Shuffle - No Tile Found") }
                if tile.status != .disintegrated {
                    guard let currentTorus = torusList.popLast() else { fatalError("MovementManager - Shuffle - No Torus Found")  }
                    tileAssignments.append((currentTorus, tile))
                    currentTorus.die(calledBy: "Shuffle")
                }
            }
            
            for tileAssignment in tileAssignments {
                waitDuration = AnimationManager.helper.shuffle(torus: tileAssignment.0, to: tileAssignment.1, takeOrb: tileAssignment.1.hasOrb)
                let encodedAssignment = ShuffledTileAssignment(torusName: tileAssignment.0.name, tilePosition: tileAssignment.1.boardPosition)
                shuffledTileAssignmentsForDecoding.append(encodedAssignment)
            }
            
            if !decoding {
                ChangeManager.register.shuffle(shuffledTileAssignmentsForDecoding, direction: direction, for: firstTorus, waitDuration: waitDuration + fadeDuration)
            }
        }
        
        return waitDuration + fadeDuration
    }
    
    //Move
    func move(_ torus: Torus, to newTile: Tile, decoding: Bool = false, floating: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        let movementType: MoveType = floating ? .float : movement(from: torus, to: newTile)
        var waitDuration: CGFloat = 0
        
        //Save opposing torus
        let opponent: Torus? = newTile.occupiedBy
        let absoluteDistance = abs((torus.currentTile.boardPosition.column - newTile.boardPosition.column)) + abs((torus.currentTile.boardPosition.row - newTile.boardPosition.row))

        torus.changeOccupancy(to: newTile)
        
        let finalAnimation = torus.activatedAttributes.isSnared ? { AnimationManager.helper.kill(torus: torus, deathType: .snare, calledBy: "AnimationManager - Move", completion: completion) } : completion
        
        if movementType == .attack {
            waitDuration = AnimationManager.helper.attack(torus: torus, to: newTile, against: opponent!) { finalAnimation() }
        } else if movementType == .orb {
            waitDuration = AnimationManager.helper.takeOrb(torus: torus, to: newTile) { finalAnimation() }
        } else if movementType == .normal {
            waitDuration = AnimationManager.helper.move(torus: torus, to: newTile) { finalAnimation() }
        } else if movementType == .float {
            waitDuration = AnimationManager.helper.float(torus: torus, to: newTile, absoluteDistance: absoluteDistance, takeOrb: newTile.hasOrb) { completion() }
        }
        
        torus.deselect()
        
        if !decoding && !floating {
            ChangeManager.register.move(torus, to: newTile)
        }
        
        return waitDuration
    }
}
