//
//  GameBoard.swift
//  Torus Neon
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit

struct TilePosition: Equatable, Codable, CustomStringConvertible, Comparable {
    static func < (lhs: TilePosition, rhs: TilePosition) -> Bool {
        if lhs.column < rhs.column {
            return true
        } else if lhs.column > rhs.column {
            return false
        } else if lhs.row < rhs.row {
            return true
        } else {
            return false
        }
    }
    
    
    var name: String {
        return "(\(column),\(row))"
    }
    
    var column: Int
    var row: Int
    var point: CGPoint
    
    var tileHeight: TileHeight
    var tileSize: CGSize

    var xDistance: CGFloat {
        return (tileSize.width / CGFloat(29)) * CGFloat(tileHeight.rawValue)
    }
    
    var yDistance: CGFloat {
        return (tileSize.height / CGFloat(31)) * CGFloat(tileHeight.rawValue)
    }
    
    func getPoint() -> CGPoint {
        
        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        xDistance = (tileSize.width / CGFloat(29)) * CGFloat(tileHeight.rawValue)
        yDistance = (tileSize.height / CGFloat(31)) * CGFloat(tileHeight.rawValue)
        
        return CGPoint(x: point.x + xDistance, y: point.y + yDistance)
    }
    
    var description: String {
        return "Tile Position - " + name
    }
}

class GameBoard: Entity {
    
    var tiles = [Tile]()
    
    var playScreen: PlayScreen
    
    var frame: CGRect {
        return playScreen.boardFrame
    }
    
    var cellSize: CGSize?
    
    
    var unoccupiedTiles: Int {
        var count = 0
        for tile in self.tiles {
            if tile.validForOrb { count += 1 }
        }
        return count
    }
    
    
    var highlightedTiles: [(tile: Tile, moveType: MoveType)]  = []
    
    init(scene: GameScene, playScreen: PlayScreen) {
        self.playScreen = playScreen
        
        let sprite = GameBoardSprite(size: playScreen.boardFrame.size)
        
        super.init(scene: scene, sprite: sprite, position: CGPoint(x: playScreen.boardFrame.midX, y: playScreen.boardFrame.midY), spriteLevel: .boardOrTray, name: "Game Board", size: playScreen.boardFrame.size)
    }
    
    func printGameBoard() {
        print(" --- GameBoard ---")
        var gameBoardString = ""
        
        for row in (0 ..< scene.numberOfRows).reversed() {
            for column in 0 ..< scene.numberOfColumns {
                
                let tile = getTile(column: column, row: row)
                var torusName = ""
                if let torus = tile?.occupiedBy {
                    torusName = "\(torus.team.teamNumber), \(torus.torusNumber.asTwoDigitNumber())"
                } else {
                    torusName = "       "
                }
                gameBoardString += "[\(column),\(row) (\(torusName))]  -  "
            }
            gameBoardString += "\n\n"
        }
        
        print(gameBoardString)
        
        print(" --- Torus Directory --- ")
        var torii = manager.team1.torii + manager.team2.torii
        torii.sort { $0.name < $1.name }
        torii.forEach { print($0.name, $0.currentTile)}
        print()
    }
}

extension GameBoard { //Setup functions
    
    func setUpTiles() {
        
        let cellSize = getCellSize()
        
        var currentX: CGFloat = frame.origin.x
        var currentY: CGFloat = frame.origin.y
        
        for row in 0 ..< scene.numberOfRows {
            for column in 0 ..< scene.numberOfColumns {
                
                let position = TilePosition(column: column, row: row, point: getCellPosition(currentX, currentY, cellSize), tileHeight: .l3, tileSize: cellSize)
                let newTile = Tile(scene: self.scene, boardPosition: position, size: cellSize)
                
                tiles.append(newTile)
                
                currentX += cellSize.width
            }
            
            currentX = frame.origin.x
            currentY += cellSize.height
        }
    }
    
    private func getCellSize() -> CGSize {
        
        let cellWidth = frame.width / CGFloat(scene.numberOfColumns)
        let cellHeight = frame.height / CGFloat(scene.numberOfRows)
        return(CGSize(width: cellWidth, height: cellHeight))
    }
    
    private func getCellPosition(_ x: CGFloat, _ y: CGFloat, _ cellSize: CGSize) -> CGPoint {
        
        let midX = x + (cellSize.width / 2)
        let midY = y + (cellSize.height / 2)
        return CGPoint(x: midX, y: midY)
    }
}

extension GameBoard { // Retrieval Functions
    
    //Retrieve tiles
    func getRandomTile() -> Tile {
        
        guard let tile = tiles.randomElement() else { fatalError("No tile found") }
        
        return tile
    }
    
    func getRandomNeighboringTile(from currentTile: Tile) -> Tile {
        
        var validTiles = [Tile]()
        
        let adjacentPairs = [(-1,0), (1,0), (0,1), (0,-1)]
        
        for (row, col) in adjacentPairs {
            if let tile = scene.gameManager.gameBoard.getTile(column: currentTile.boardPosition.column + col, row: currentTile.boardPosition.row + row) {
                validTiles.append(tile)
            }
        }
        
        guard let resultTile = validTiles.randomElement() else { fatalError("GameBoard - GetRandomNeighboringTile - No tile found") }
        
        return resultTile
    }
    
    func getTile(from position: TilePosition?) -> Tile? {
        
        guard let position = position else { return nil }
        
        for tile in tiles { // NOTE: Make efficient?
            if tile.boardPosition.name == position.name {
                return tile
            }
        }
        
        return nil
    }
    
    func getTile(column: Int, row: Int) -> Tile? {
        
        for tile in tiles { // NOTE: Make efficient?
            if tile.boardPosition.column == column && tile.boardPosition.row == row {
                return tile
            }
        }
        
        return nil
    }
    
    func getTileForOrb(from index: Int) -> Tile? {
        
        let tile = tiles[index]
        
        if tile.hasOrb || tile.occupiedBy != nil || tile.status == .disintegrated {
            return nil
        } else {
            return tile
        }
    }
}

extension GameBoard { //Valid tiles
    
    func highlightValidTiles(surrounding torus: Torus) {
        
        highlightedTiles  = MovementManager.helper.getValidMoves(for: torus)
        highlightedTiles.forEach { $0.tile.isValidForMovement(moveType: $0.moveType) }
    }
    
    func unhighlightTiles() {
        
        highlightedTiles.forEach { $0.tile.isInvalidForMovement() }
        highlightedTiles = []
    }
}
