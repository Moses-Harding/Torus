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
        
        print("\nMovementManager - decodedScramble")
        print("ScrambledList -")
        for pair in scrambledList {
            print(pair.tilePosition, pair.torusName)
        }
        print()
        
        var tileAssignments = [(Torus, Tile)]()
        
        var waitDuration: CGFloat = 0.5
        let fadeDuration: CGFloat = 0.5
        
        scrambledList.forEach {
            guard let torus = scene.gameManager.getTorus(with: $0.torusName) else { fatalError("MovementManager - decodedScramble - Torus \($0.torusName) could not be located") }
            torus.sprite.run(SKAction.group([SKAction.fadeOut(withDuration: fadeDuration), SKAction.scale(to: 1.2, duration: fadeDuration)]))
        }
        
        scene.run(SKAction.wait(forDuration: fadeDuration)) {
            print("Iterating through scrambled list")
            for eachPair in scrambledList {
                guard let torus = self.scene.gameManager.getTorus(with: eachPair.torusName) else { fatalError("MovementManager - decodedScramble - Torus \(eachPair.torusName) could not be located") }
                guard let tile = self.scene.gameManager.gameBoard.getTile(from: eachPair.tilePosition) else { fatalError("MovementManager - decodedScramble - Tile \(eachPair.tilePosition) could not be located") }
                tileAssignments.append((torus, tile))
                tile.occupiedBy = nil
                torus.die(calledBy: "Decoded Scramble")
            }
            
            print("Iterating through assignment list")
            for tileAssignment in tileAssignments {
                //print("\n\(tileAssignment.0), which is currently at \(tileAssignment.0.currentTile), will move to \(tileAssignment.1).\n\(tileAssignment.0.currentTile)'s current occupant is \(String(describing: tileAssignment.0.currentTile.occupiedBy)), and \(tileAssignment.1)'s current occupant is \(tileAssignment.1.occupiedBy)")
                waitDuration = AnimationManager.helper.scramble(torus: tileAssignment.0, to: tileAssignment.1, takeOrb: tileAssignment.1.hasOrb)
            }
        }
        
        return waitDuration + fadeDuration
    }
    
    func scramble(_ torii: [Torus], tiles: [Tile], direction: PowerDirection, decoding: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        print("\nMovementManager - Scramble")
        print("Torii - \(torii)")
        print("Tiles - \(tiles)")
        tiles.forEach { print("\($0) occupied by \($0.occupiedBy)")}
        
        var torusList = torii
        var tileList = tiles
        
        var waitDuration: CGFloat = 0.5
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
                    currentTorus.die(calledBy: "Scramble")
                }
            }
            
            for tileAssignment in tileAssignments {
                waitDuration = AnimationManager.helper.scramble(torus: tileAssignment.0, to: tileAssignment.1, takeOrb: tileAssignment.1.hasOrb)
                let encodedAssignment = ScrambledTileAssignment(torusName: tileAssignment.0.name, tilePosition: tileAssignment.1.boardPosition)
                scrambledTileAssignmentsForDecoding.append(encodedAssignment)
            }
            
            if !decoding {
                ChangeManager.register.scramble(scrambledTileAssignmentsForDecoding, direction: direction, for: firstTorus, waitDuration: waitDuration + fadeDuration)
            }
        }
        
        return waitDuration + fadeDuration
    }
    
    //Move
    func move(_ torus: Torus, to newTile: Tile, decoding: Bool = false, relocating: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        let movementType: MoveType = relocating ? .relocate : movement(from: torus, to: newTile)
        var waitDuration: CGFloat = 0
        
        //Save opposing torus
        let opponent: Torus? = newTile.occupiedBy
        
        
        let absoluteDistance = abs((torus.currentTile.boardPosition.column - newTile.boardPosition.column) + (torus.currentTile.boardPosition.row - newTile.boardPosition.row))
        
        let oldTile = torus.currentTile
        
        print("Movement Start - \(torus), Old Tile: \(oldTile), New Tile: \(newTile), MovementType: \(movementType)")
        
        torus.changeOccupancy(to: newTile)
        
        let finalAnimation = torus.activatedAttributes.isTripWired ? { AnimationManager.helper.kill(torus: torus, deathType: .tripwire, calledBy: "AnimationManager - Move", completion: completion) } : completion
        
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
        }
        
        return waitDuration
    }
}
