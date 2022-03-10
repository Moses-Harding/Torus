//
//  GameBoard.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit

struct TilePosition: Equatable, Codable {
    
    var name: String {
        return "(\(column),\(row))"
    }
    
    var column: Int
    var row: Int
    var point: CGPoint
    
    var tileHeight: TileHeight
    var tileSize: CGSize
    
    func getPoint() -> CGPoint {
        
        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        xDistance = (tileSize.width / 26) * CGFloat(tileHeight.rawValue)
        yDistance = (tileSize.height / 26) * CGFloat(tileHeight.rawValue)
        
        return CGPoint(x: point.x + xDistance, y: point.y + yDistance)
    }
}

class GameBoard: Entity {
    
    var tiles = [Tile]()
    
    var unoccupiedTiles = [Tile]()
    
    var playScreen: PlayScreen
    
    var frame: CGRect {
        return playScreen.boardFrame
    }
    
    var cellSize: CGSize?
    
    var highlightedTiles: [(tile: Tile, moveType: MoveType)]  = []
    
    init(scene: GameScene, playScreen: PlayScreen) {
        self.playScreen = playScreen
        
        let sprite = GameBoardSprite(size: playScreen.boardFrame.size)
        
        super.init(scene: scene, sprite: sprite, position: CGPoint(x: playScreen.boardFrame.midX, y: playScreen.boardFrame.midY), spriteLevel: .boardOrTray, name: "Game Board", size: playScreen.boardFrame.size)
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
                
                
                if newTile.occupiedBy == nil {
                    unoccupiedTiles.append(newTile)
                }
                
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
    
    func syncUnoccupiedTiles() {
        
        for tile in tiles {
            if tile.occupiedBy == nil {
                unoccupiedTiles.append(tile)
            }
        }
    }
}

extension GameBoard { // Retrieval Functions
    
    //Retrieve tiles
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
        
        let tile = unoccupiedTiles[index]
        return tile.validForOrb ? tile : nil
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
    
    func unoccupied(_ tile: Tile) {
        unoccupiedTiles.append(tile)
    }
    
    func occupied(_ tile: Tile) {
        unoccupiedTiles.removeAll { $0 == tile }
    }
}
