//
//  Tile.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit



final class Tile: Entity {
    
    //Tile Status
    var height = TileHeight.l3
    var status = TileStatus.normal
    
    //Position And Size
    var boardPosition: TilePosition
    
    //Associated Torus
    var occupiedBy: Torus?
    
    //Has Orb
    var hasOrb = false
    
    //Select
    var validForMovement = false
    
    var validForOrb: Bool {
        return status == .normal && occupiedBy == nil && !hasOrb
    }
    
    var normalTexture = TileAssets.l3.rawValue
    var acidTexture = TileAssets.acidTile.rawValue
    
    var moveSelectionOverlay: MoveSelectionOverlay?
    var orbOverlay: OrbOverlay? {
        didSet {
            //print("Orb Texture changed to \(orbOverlay) on \(self.name)")
            //print("NOTE - associate individual powers with given orbs")
        }
    }
    var nextPower: PowerType?
    
    init(scene: GameScene, boardPosition: TilePosition, size: CGSize) {
        
        self.boardPosition = boardPosition
        
        let sprite = TileSprite(size: size)
        
        super.init(scene: scene, sprite: sprite, position: boardPosition.point, spriteLevel: .tileOrTrayItem, name: "Tile\(boardPosition.name)", size: size)
    }
    
    //Was Touched
    override func wasTouched() {
        manager.select(self)
    }
}

extension Tile { //Manipulation
    
    //Selected
    func isValidForMovement(moveType: MoveType) {
        
        validForMovement = true
        if moveSelectionOverlay == nil {
            moveSelectionOverlay = MoveSelectionOverlay(size: sprite.size, tileHeight: height, moveType: moveType, parentSprite: sprite)
        }
    }
    
    func isInvalidForMovement() {
        
        validForMovement = false
        moveSelectionOverlay?.removeFromParent()
        moveSelectionOverlay = nil
    }
    
    //Occupancy
    func occupy(with torus: Torus) {

        occupiedBy = torus
    }
    
    func unoccupy() {
        
        occupiedBy = nil
    }
    
    func populateOrb(decoding: Bool = false, nextPower: PowerType? = nil) {
        
        if TestingManager.helper.verbose { print("Populating orb on \(self.boardPosition)") }

        hasOrb = true
        
        if AnimationManager.helper.isFirstTurn {
            //print("Populating orb on tile \(self.name) - first turn")
            orbOverlay = OrbOverlay(parentSize: sprite.size, parentSprite: sprite)
            orbOverlay?.position = CGPoint(x: CGFloat(height.rawValue * 2), y: CGFloat(height.rawValue * 2))
            AnimationManager.helper.isFirstTurn = false
        } else if orbOverlay == nil {
            //print("Populating orb on tile \(self.name) - not first turn")
            AnimationManager.helper.populateOrb(self)
        }

        if decoding {
            guard let power = nextPower else { fatalError("No power passed to populate orb when decoding") }
            self.nextPower = power
        } else {
            guard let power = TestingManager.helper.testPowers ? TestingManager.helper.powersToTest.randomElement() : PowerType.random() else { fatalError("No power retrieved to assign to tile") }
            self.nextPower = power
            ChangeManager.register.populateOrb(on: self, nextPower: self.nextPower!)
        }
    }
    
    func removeOrb(completion: @escaping (() -> ()) ) {
        
        hasOrb = false
        
        self.nextPower = nil
        self.orbOverlay?.removeFromParent()
        self.orbOverlay = nil
        completion()
    }
    
    func invert() {
        
        var newHeight: TileHeight
        
        switch self.height {
        case .l1:
            newHeight = .l5
        case .l2:
            newHeight = .l4
        case .l3:
            newHeight = .l3
        case .l4:
            newHeight = .l2
        case .l5:
            newHeight = .l1
        }
        
        changeHeight(to: newHeight)
    }
    
    func changeHeight(to newHeight: TileHeight) {
        
        guard newHeight != self.height else { return }
        
        guard let tileSprite = self.sprite as? TileSprite else { fatalError("Cannot cast Tile's Sprite to TileSprite") }
        
        height = newHeight
        tileSprite.changeHeight(to: newHeight)
        boardPosition.tileHeight = newHeight
        
        if let currentTorus = occupiedBy {
            currentTorus.sprite.position = boardPosition.getPoint()
        }
        
        if let orb = orbOverlay {
            orb.position = orb.position.move(.right, by: boardPosition.xDistance).move(.up, by: boardPosition.yDistance)
        }
    }
    
    func changeStatus(to newStatus: TileStatus) {
        if status == .acid {
            self.acid()
        } else if status != .normal {
           print("STATUS NOT ACCOUNTED FOR")
        }
    }
    
    func acid() {
        
        guard let tileSprite = self.sprite as? TileSprite else { fatalError("Cannot cast Tile's Sprite to TileSprite") }
        
        tileSprite.acid()
        self.status = .acid
        
        if hasOrb {
            removeOrb {}
        }
    }
    
    func snakeTunnel(teamToAvoid: TeamNumber) -> Torus? {
        
        //print("SnakeTunnel for \(self)")
        
        guard self.status != .acid else { return nil }
        
        changeHeight(to: TileHeight.l5)
        
        if occupiedBy?.team.teamNumber != teamToAvoid {
            return occupiedBy
        } else {
            return nil
        }
    }
    
    func bomb() {
        
        if height == .l1 {
            acid()
        } else {
            lower()
        }
    }
}

extension Tile: CustomStringConvertible {
    var description: String {
        return "Tile at \(boardPosition.column), \(boardPosition.row)"
    }
}

extension Tile: Equatable {
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.description == rhs.description
    }
}

extension Tile { //Raise And Lower

    func raise() {

        switch height {
        case .l1:
            changeHeight(to: .l2)
        case .l2:
            changeHeight(to: .l3)
        case .l3:
            changeHeight(to: .l4)
        case .l4:
            changeHeight(to: .l5)
        case .l5:
            //changeHeight(to: .l5)
            print("Max Height Reached")
        }
    }
    
    func lower() {

        switch height {
        case .l1:
            print("Max Depth Reached")
            //changeHeight(to: .l1)
        case .l2:
            changeHeight(to: .l1)
        case .l3:
            changeHeight(to: .l2)
        case .l4:
            changeHeight(to: .l3)
        case .l5:
            changeHeight(to: .l4)
        }
    }
}

extension Tile { //Populate Tile Based Off Of Description
    
    func loadDescription(_ description: TileDescription) {
        
        changeStatus(to: description.status)
        changeHeight(to: description.height)
        if description.hasOrb {
            populateOrb(decoding: true, nextPower: description.nextPower)
        }
    }
}
