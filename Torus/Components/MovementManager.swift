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
    
    //Move
    func move(_ torus: Torus, to newTile: Tile, decoding: Bool = false, relocating: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        let movementType: MoveType = relocating ? .relocate : movement(from: torus, to: newTile)
        var waitDuration: CGFloat = 0
        
        //Save opposing torus
        let opponent: Torus? = newTile.occupiedBy

        
        let absoluteDistance = abs((torus.currentTile.boardPosition.column - newTile.boardPosition.column) + (torus.currentTile.boardPosition.row - newTile.boardPosition.row))
        
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
        
        if !decoding {
            ChangeManager.register.move(torus, to: newTile)
            //ChangeManager.register.syncPowers(for: torus)
        } else {
            print("Is currently decoding")
        }
        
        return waitDuration
    }
}
