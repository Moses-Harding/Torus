//
//  MovementManager.swift
//  Triple Bomb
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
        
        return (torus.activatedAttributes.hasMoveDiagonal && abs(colSum) == 1 && abs(rowSum) == 1 ) || abs(colSum + rowSum) == 1
    }
    
    private func heightIsValid(from torus: Torus, to tile: Tile) -> Bool {
        
        return torus.activatedAttributes.hasClimbTile || (torus.currentTile.height.rawValue - tile.height.rawValue >= -1)
    }
    
    private func moveType(for torus: Torus, to tile: Tile) -> MoveType {
        
        guard let occupant = tile.occupiedBy else { return tile.hasOrb && !torus.activatedAttributes.isInhibited ? .orb : .normal }
        
        return occupant.team == torus.team || occupant.activatedAttributes.hasJumpProof ? .invalid : .attack
    }
    
    private func statusIsValid(for tile: Tile) -> Bool {
        
        return tile.status == .acid ? false : true
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
    
    func decodedScramble(scrambledList: [ScrambledTileAssignment]) -> CGFloat {
        
        var tileAssignments = [(Torus, Tile)]()
        
        var waitDuration: CGFloat = 0
        let fadeDuration: CGFloat = 0.5
        
        
        for eachPair in scrambledList {
            guard let torus = scene.gameManager.getTorus(with: eachPair.torusName) else { fatalError("MovementManager - decodedScramble - Torus \(eachPair.torusName) could not be located")}
            guard let tile = scene.gameManager.gameBoard.getTile(from: eachPair.tilePosition) else { fatalError("MovementManager - decodedScramble - Tile \(eachPair.tilePosition) could not be located") }
            torus.sprite.run(SKAction.group([SKAction.fadeOut(withDuration: fadeDuration), SKAction.scale(to: 1.2, duration: fadeDuration)])) {
                torus.die()
            }
            tileAssignments.append((torus, tile))
        }
        
        guard let firstTorus = tileAssignments.first?.0 else { fatalError("MovementManager - decodedScramble - TileAssignemnts list is empty")}
        
        firstTorus.sprite.run(SKAction.wait(forDuration: fadeDuration)) {

            for tileAssignment in tileAssignments {
                waitDuration = AnimationManager.helper.scramble(torus: tileAssignment.0, to: tileAssignment.1, takeOrb: tileAssignment.1.hasOrb)
            }
        }
        
        return waitDuration + fadeDuration
    }
    
    func scramble(_ torii: [Torus], tiles: [Tile], decoding: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        print("Registering scramble")
        
        var torusList = torii
        var tileList = tiles
        
        //print("Torus list - \(torusList)")
        //print("Tile list - \(tileList)")
        
        var waitDuration: CGFloat = 0
        let fadeDuration: CGFloat = 0.5
        
        var tileAssignments = [(Torus, Tile)]()
        var scrambledTileAssignmentsForDecoding = [ScrambledTileAssignment]()
        
        torusList.forEach {
            $0.sprite.run(SKAction.group([SKAction.fadeOut(withDuration: fadeDuration), SKAction.scale(to: 1.2, duration: fadeDuration)]))
        }
        
        guard let firstTorus = torusList.first else { fatalError("PowerManager - Scramble - No First Torus Found")  }
        
        firstTorus.sprite.run(SKAction.wait(forDuration: fadeDuration)) {
            while torusList.count > 0 && tileList.count > 0 {
                guard let tile = tileList.popLast() else { fatalError("PowerManager - Scramble - No Tile Found") }
                if tile.status != .acid {
                    guard let currentTorus = torusList.popLast() else { fatalError("PowerManager - Scramble - No Torus Found")  }
                    tileAssignments.append((currentTorus, tile))
                    currentTorus.die()
                }
            }
            
            
            for tileAssignment in tileAssignments {
                waitDuration = AnimationManager.helper.scramble(torus: tileAssignment.0, to: tileAssignment.1, takeOrb: tileAssignment.1.hasOrb)
                let encodedAssignment = ScrambledTileAssignment(torusName: tileAssignment.0.name, tilePosition: tileAssignment.1.boardPosition)
                scrambledTileAssignmentsForDecoding.append(encodedAssignment)
            }
            
            if !decoding {
                ChangeManager.register.scramble(scrambledTileAssignmentsForDecoding, for: firstTorus, waitDuration: waitDuration + fadeDuration)
            }
        }

        return waitDuration + fadeDuration
    }
    
    //Move
    func move(_ torus: Torus, to newTile: Tile, decoding: Bool = false, relocating: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        var movementType: MoveType = relocating ? .relocate : movement(from: torus, to: newTile)
        var waitDuration: CGFloat = 0
        
        //Save opposing torus
        let opponent: Torus? = newTile.occupiedBy
        
        
        let absoluteDistance = abs((torus.currentTile.boardPosition.column - newTile.boardPosition.column) + (torus.currentTile.boardPosition.row - newTile.boardPosition.row))
        
        let oldTile = torus.currentTile
        
        print("Movement Start - \(torus), Old Tile: \(oldTile), New Tile: \(newTile), MovementType: \(movementType)")
        
        torus.changeOccupancy(to: newTile)
        
        let finalAnimation = torus.activatedAttributes.isTripWired ? { AnimationManager.helper.kill(torus: torus, deathType: .tripwire, completion: completion) } : completion
        
        if movementType == .attack {
            waitDuration = AnimationManager.helper.attack(torus: torus, to: newTile, against: opponent!) { finalAnimation() }
        } else if movementType == .orb {
            waitDuration = AnimationManager.helper.takeOrb(torus: torus, to: newTile) { finalAnimation() }
        } else if movementType == .normal {
            waitDuration = AnimationManager.helper.move(torus: torus, to: newTile) { finalAnimation() }
        } else if movementType == .relocate {
            waitDuration = AnimationManager.helper.relocate(torus: torus, to: newTile, absoluteDistance: absoluteDistance, takeOrb: newTile.hasOrb) { completion() }
        }
        
        torus.deselect()
        
        //print("Movement End - \(torus), Old Tile Occupied Status: \(oldTile.occupiedBy), New Tile Occupied Status: \(newTile.occupiedBy)")
        
        if !decoding {
            print("Registering movement")
            ChangeManager.register.move(torus, to: newTile)
            //ChangeManager.register.syncPowers(for: torus)
        } else {
            print("Movement Manager - Decoding Movement")
        }
        
        return waitDuration
    }
}
