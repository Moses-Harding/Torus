//
//  Team.swift
//  Triple Bomb
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
    var torii = [Torus]()
    var teamColor: TorusColor
    
    var gameManager: GameManager
    var scene: GameScene {
        return gameManager.scene
    }
    
    var currentlySelected: Torus?
    
    var torusSize: CGSize
    
    var teamCount: Int {
        return torii.count
    }
    
    init(teamNumber: TeamNumber, teamColor: TorusColor?, gameManager: GameManager) {
        
        self.teamNumber = teamNumber
        self.teamColor = teamNumber == .one ? .red : .blue
        self.gameManager = gameManager
        self.torusSize = CGSize.zero
    }

    
    func createTeam() {
        
        print("Creating team")
        
        var currentRow = 0
        var currentCol = 0
        
        var torusNumber = 0
        
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
                
                let torus = Torus(scene: gameManager.scene, number: torusNumber, team: self, color: teamColor, currentTile: tile, size: tile.size)
                torii.append(torus)
                torusNumber += 1
                
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
