//
//  Team.swift
//  Torus Neon
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit

enum TeamNumber: Codable {
    case one, two
}

class Team {
    
    var teamNumber: TeamNumber
    var oppositeTeam: TeamNumber
    var torii = [Torus]()
    var teamColor: TorusColor
    
    var gameManager: GameManager
    var scene: GameScene { return gameManager.scene }
    
    var currentlySelected: Torus?
    
    var torusSize: CGSize
    
    var teamCount: Int {
        return torii.count
    }
    
    var lastNumber: Int = 0
    
    init(teamNumber: TeamNumber, teamColor: TorusColor?, gameManager: GameManager) {
        
        self.teamNumber = teamNumber
        self.oppositeTeam = teamNumber == .one ? .two : .one
        self.teamColor = teamNumber == .one ? .red : .blue
        self.gameManager = gameManager
        self.torusSize = CGSize.zero
    }
    
    func addTorus(at position: TilePosition) -> Torus {
        
        guard let tile = gameManager.gameBoard.getTile(from: position), tile.occupiedBy == nil else { fatalError("Team - Add Torus - Cannot Add To Tile") }
        
        lastNumber += 1

        let torus = Torus(scene: gameManager.scene, number: lastNumber, team: self, color: teamColor, currentTile: tile, size: tile.size)
        torii.append(torus)
        
        return torus
    }
    
    func addTorus(from torus: Torus, override boardPosition: TilePosition? = nil, keepNumber: Bool = false) -> Torus {

        let boardPosition = boardPosition ?? torus.currentTile.boardPosition
        
        guard let tile = gameManager.gameBoard.getTile(from: boardPosition) else { fatalError("Team - Add Torus - Cannot Get Tile") }
                
        if TestingManager.helper.verboseTiles { print("Team - Add Torus - Adding \(torus) to \(tile)") }
        
        guard tile.occupiedBy == nil else { fatalError("Team - Add Torus - Trying to add \(torus) but \(tile) is occupied by \(String(describing: tile.occupiedBy))") }
        
        var torusNumber = 1
        
        if keepNumber {
            torusNumber = torus.torusNumber
        } else {
            torusNumber = lastNumber
            lastNumber += 1
        }
        
        let description = TorusDescription(color: self.teamColor, teamNumber: self.teamNumber, torusNumber: torusNumber, powers: torus.powers, attributes: torus.activatedAttributes, currentTile: boardPosition)

        
        let torus = Torus(scene: gameManager.scene, number: torusNumber, team: self, color: teamColor, currentTile: tile, size: tile.size)
        torus.loadDescription(description: description)
        torii.append(torus)
        
        if TestingManager.helper.verboseTiles { print("Team - Add Torus - Added \(torus) to \(tile)") }
        
        return torus
    }

    
    func createTeam() {

        var currentRow = 0
        var currentCol = 0
        
        let numberOfOccupiedRowsPerTeam = 3
        
        guard numberOfOccupiedRowsPerTeam * 2 <= scene.numberOfRows else {
            fatalError("Attempting to add more toruses than possible (In Team - createTeam)")
        }
        
        if teamNumber == .two {
            currentRow = (numberOfOccupiedRowsPerTeam) + (scene.numberOfRows - (numberOfOccupiedRowsPerTeam * 2))
        }
        
        for _ in 0 ..< numberOfOccupiedRowsPerTeam {
            for _ in 0 ..< scene.numberOfColumns {
                guard let tile = gameManager.gameBoard.getTile(column: currentCol, row: currentRow) else {
                    fatalError("Attempting to get tile that does not exist")
                }
                
                let torus = Torus(scene: gameManager.scene, number: lastNumber, team: self, color: teamColor, currentTile: tile, size: tile.size)
                torii.append(torus)
                lastNumber += 1
                
                currentCol += 1
            }
            currentRow += 1
            currentCol = 0
        }
    }
    
    func loadTeam(from descriptions: [TorusDescription]) {
        
        for description in descriptions {
            guard let tile = gameManager.gameBoard.getTile(from: description.currentTile) else { fatalError("Loading Tile - Relevant tile not found") }
            let torus = Torus(scene: gameManager.scene, tile: tile, team: self, size: tile.size, description: description)
            torii.append(torus)
        }
    }
    
    func remove(torus: Torus) {
        torii.removeAll { $0.name == torus.name }
    }
    
    func getTorus(with name: String) -> Torus? {
        for torus in torii {
            if torus.name == name {
                return torus
            }
        }
        
        return nil
    }
}

extension Team: Equatable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.teamNumber == rhs.teamNumber
    }
}
