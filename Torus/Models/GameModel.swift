//
//  GameModal.swift
//  Torus Neon
//
//  Created by Moses Harding on 2/23/22.
//

import Foundation
import GameKit

struct GameModel: Codable {
    
    //Match
    var messageToDisplay: String { return "Your turn!" }
    
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
    var team1LastNumber = 0
    var team2LastNumber = 0
    
    var postTurnTiles = [TileDescription]()
    var postTurnTeam1Torii = [TorusDescription]()
    var postTurnTeam2Torii = [TorusDescription]()
    var postTurnTeam1LastNumber = 0
    var postTurnTeam2LastNumber = 0
    
    //Changes
    var changes = [Change]()
    
    mutating func savePreTurnData(from scene: GameScene) {
        
        print("\nSaving Pre-Turn Data")
        
        guard let manager = scene.gameManager else { fatalError("GameModel - SavePreTurnData - Game manager not passed") }
        
        tiles = []
        team1Torii = []
        team2Torii = []
        
        for tile in manager.gameBoard.tiles {
            let tileDescription = TileDescription(position: tile.boardPosition, height: tile.height, status: tile.status, hasOrb: tile.hasOrb, nextPower: tile.nextPower)
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
        
        team1LastNumber = manager.team1.lastNumber
        team2LastNumber = manager.team2.lastNumber
    }
    
    mutating func savePostTurnData(from scene: GameScene) {
        
        print("\nSaving Post-Turn Data")
        
        guard let manager = scene.gameManager else { fatalError("GameModel - SavePreTurnData - Game manager not passed") }
        
        postTurnTiles = []
        postTurnTeam1Torii = []
        postTurnTeam2Torii = []
        
        for tile in manager.gameBoard.tiles {
            let tileDescription = TileDescription(position: tile.boardPosition, height: tile.height, status: tile.status, hasOrb: tile.hasOrb, nextPower: tile.nextPower)
            postTurnTiles.append(tileDescription)
        }
        
        for torus in manager.team1.torii {
            let torusDescription = TorusDescription(color: torus.torusColor, teamNumber: torus.team.teamNumber, torusNumber: torus.torusNumber, powers: torus.powers, attributes: torus.activatedAttributes, currentTile: torus.currentTile.boardPosition)
            postTurnTeam1Torii.append(torusDescription)
        }
        
        for torus in manager.team2.torii {
            let torusDescription = TorusDescription(color: torus.torusColor, teamNumber: torus.team.teamNumber, torusNumber: torus.torusNumber, powers: torus.powers, attributes: torus.activatedAttributes, currentTile: torus.currentTile.boardPosition)
            postTurnTeam2Torii.append(torusDescription)
        }
        
        postTurnTeam1LastNumber = manager.team1.lastNumber
        postTurnTeam2LastNumber = manager.team2.lastNumber
    }
    
    mutating func loadPreTurnData(to scene: GameScene) {
        
        print("\nLoading Pre-Turn Data")
        
        guard let manager = scene.gameManager else { fatalError("Load PreTurnData - Game manager not passed") }
        
        for tile in tiles {
            guard let foundTile = manager.gameBoard.getTile(from: tile.position) else { fatalError("Load PreTurnData - Tile not found") }
            foundTile.loadDescription(tile)
        }

        manager.team1.loadTeam(from: team1Torii)
        manager.team2.loadTeam(from: team2Torii)
        manager.team1.lastNumber = team1LastNumber
        manager.team2.lastNumber = team2LastNumber
    }

    
    mutating func loadPostTurnData(to scene: GameScene) {
        
        print("\nLoading Post-Turn Data")

        guard let manager = scene.gameManager else { fatalError("Load PreTurnData - Game manager not passed") }
        
        for tile in postTurnTiles {
            guard let foundTile = manager.gameBoard.getTile(from: tile.position) else { fatalError("Load PreTurnData - Tile not found") }
            foundTile.loadDescription(tile)
        }
        manager.team1.loadTeam(from: postTurnTeam1Torii)
        manager.team2.loadTeam(from: postTurnTeam2Torii)
        manager.team1.lastNumber = postTurnTeam1LastNumber
        manager.team2.lastNumber = postTurnTeam2LastNumber
    }
    
    mutating func loadData(to scene: GameScene, matchAlreadyOpen: Bool) {
        
        print("\nLoading Data")
        
        print(self)
        
        guard let manager = scene.gameManager else { fatalError("Load Data - Game manager not passed") }
        
        manager.turnNumber = turnNumber
        manager.changeTeam(to: currentTeam)

        if !matchAlreadyOpen { loadPreTurnData(to: scene) }
        
        ChangeDecoder.helper.decode(changes) //NOTE: PRE TURN DATA SAVED AFTER THIS

        changes = []
        ChangeManager.register.refresh()
    }
    
    mutating func saveData(from scene: GameScene) {
        
        print("\nSaving Data")
        
        guard let manager = scene.gameManager else { fatalError("Save Data - Game manager not passed") }
        
        turnNumber = manager.turnNumber
        currentTeam = manager.currentTeam.teamNumber
        winner = manager.winnerFound()
        team1Score = manager.team1.teamCount
        team2Score = manager.team2.teamCount
        
        changes = ChangeManager.register.changes
        
        ChangeManager.register.refresh()
    }
}

struct TileDescription: Codable {
    var position: TilePosition
    var height: TileHeight
    var status: TileStatus
    var hasOrb: Bool
    var nextPower: PowerType?
}

struct TorusDescription: Codable {
    var color: TorusColor
    var teamNumber: TeamNumber
    var torusNumber: Int
    var powers: [PowerType:Int]
    var attributes: ActivatedAttributes
    var currentTile: TilePosition
}

extension Change: CustomStringConvertible {
    var description: String {
        let description = "\(self.torus) - \(self.type)"
        return description
    }
}

extension OrbAssignment: CustomStringConvertible {
    var description: String {
        let description = "\(self.tile.name) - \(self.nextPower)"
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
        let powerName = hasOrb ? " - has \(nextPower!)" : ""
        return "Tile \(position.name)\(powerName)"
    }
}

extension GameModel: CustomStringConvertible {
    var description: String {
        var description = "Game Model Summary - \n"
        description += "Players - \(player1 ?? "None") and \(player2 ?? "None")\n"
        description += "Score - \(team1Score) and \(team2Score)\n"
        description += "Turn - \(turnNumber); Current Team - \(currentTeam), Winner - \(String(describing: winner))\n"
        description += "Tiles And Torii Accounted for - \(tiles.count), \(team1Torii.count), and \(team2Torii.count)\n"
        description += "Changes - \(changes)\n"
        return description
    }
}
