//
//  GameModal.swift
//  Torus
//
//  Created by Moses Harding on 2/23/22.
//

import Foundation
import GameKit

struct GameModel: Codable {
    
    //Match
    var messageToDisplay: String {
        return "Your turn!"
    }
    
    //Turn
    var turnNumber: Int = 0
    var firstMove = true

    //Players
    var player1: String? = nil
    var player2: String? = nil
    
    //Teams
    var currentTeam: TeamNumber = .one
    var winner: TeamNumber?
    var team1Score = 0
    var team2Score = 0
    
    //Saved Data
    var tiles = [TileDescription]()
    var team1Torii = [TorusDescription]()
    var team2Torii = [TorusDescription]()
    
    //Changes
    var tileChanges = [TileChange]()
    var torusChanges = [TorusChange]()
    
    mutating func savePreTurnData(from scene: GameScene) {
        
        print("Saving Pre-Turn Data")
        
        guard let manager = scene.gameManager else { fatalError("Save PreTurnData - Game manager not passed") }
        
        tiles = []
        team1Torii = []
        team2Torii = []
        
        for tile in manager.gameBoard.tiles {
            let tileDescription = TileDescription(position: tile.boardPosition, height: tile.height, status: tile.status, hasOrb: tile.hasOrb)
            tiles.append(tileDescription)
        }
        
        for torus in manager.team1.torii {
            let torusDescription = TorusDescription(color: torus.torusColor, teamNumber: torus.team.teamNumber, torusNumber: torus.torusNumber, powers: torus.powers, attributes: torus.activatedAttributes, currentTile: torus.currentTile.boardPosition)
            team1Torii.append(torusDescription)
        }
        
        for torus in manager.team2.torii {
            let torusDescription = TorusDescription(color: torus.torusColor, teamNumber: torus.team.teamNumber, torusNumber: torus.torusNumber, powers: torus.powers, attributes: torus.activatedAttributes, currentTile: torus.currentTile.boardPosition)
            team2Torii.append(torusDescription)
        }
    }
    
    mutating func loadPreTurnData(to scene: GameScene) {
        
        print("Loading Pre-Turn Data")
        
        guard let manager = scene.gameManager else { fatalError("Load PreTurnData - Game manager not passed") }
        
        for tile in tiles {
            guard let foundTile = manager.gameBoard.getTile(from: tile.position) else { fatalError("Load PreTurnData - Tile not found") }
            foundTile.loadDescription(tile)
        }
        
        manager.team1.loadTeam(from: team1Torii)
        manager.team2.loadTeam(from: team2Torii)
    }
    
    mutating func loadData(to scene: GameScene, matchAlreadyOpen: Bool) {
        
        print("Loading Data")
        
        guard let manager = scene.gameManager else { fatalError("Load Data - Game manager not passed") }
        
        manager.turnNumber = turnNumber
        
        manager.changeTeam(to: currentTeam)
        
        if !matchAlreadyOpen { loadPreTurnData(to: scene) }
        
        ChangeDecoder.helper.decode(tileChanges: tileChanges)
        ChangeDecoder.helper.decode(torusChanges: torusChanges)
        
        savePreTurnData(from: scene)
        
        torusChanges = []
        tileChanges = []
        ChangeManager.register.refresh()
    }
    
    mutating func saveData(from scene: GameScene) {
        
        print("Saving Data")
        
        guard let manager = scene.gameManager else { fatalError("Save Data - Game manager not passed") }
        
        turnNumber = manager.turnNumber
        currentTeam = manager.currentTeam.teamNumber
        winner = manager.winnerFound()
        team1Score = manager.team1.teamCount
        team2Score = manager.team2.teamCount
        
        
        tileChanges = ChangeManager.register.tileChanges
        torusChanges = ChangeManager.register.torusChanges
        
        ChangeManager.register.refresh()
    }
}

struct TileDescription: Codable {
    var position: TilePosition
    var height: TileHeight
    var status: TileStatus
    var hasOrb: Bool
}

struct TorusDescription: Codable {
    var color: TorusColor
    var teamNumber: TeamNumber
    var torusNumber: Int
    var powers: [PowerType:Int]
    var attributes: ActivatedAttributes
    var currentTile: TilePosition
}

extension TorusChange: CustomStringConvertible {
    var description: String {
        let description = "\(self.torus) - \(self.type)"
        return description
    }
}

extension TileChange: CustomStringConvertible {
    var description: String {
        let description = "\(self.tile.name) - \(self.type)"
        return description
    }
}

extension TorusDescription: CustomStringConvertible {
    var description: String {
        return "Torus \(teamNumber) - \(torusNumber), \(attributes.description)"
    }
}

extension TileDescription: CustomStringConvertible {
    var description: String {
        return "Tile \(position.name)"
    }
}

extension GameModel: CustomStringConvertible {
    var description: String {
        var description = "Game Model Summary - \n"
        description += "Players - \(player1 ?? "None") and \(player2 ?? "None")\n"
        description += "Score - \(team1Score) and \(team2Score)\n"
        description += "Turn - \(turnNumber); Current Team - \(currentTeam), Winner - \(winner)\n"
        description += "Tiles And Torii Accounted for - \(tiles.count), \(team1Torii.count), and \(team2Torii.count)\n"
        description += "Tile Changes - \(tileChanges)\n"
        description += "Torus Changes - \(torusChanges)\n"
        return description
    }
}
