//
//  Torus.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit
import UIKit



class Torus: Entity {
    
    var torusColor: TorusColor
    
    var torusNumber: Int
    var team: Team
    
    var powers = [PowerType:Int]()
    var activatedAttributes = ActivatedAttributes()
    
    var currentTile: Tile
    
    var isSelected = false
    
    var hasPowers: Bool {
        return !powers.isEmpty
    }
    
    //Sprite Names
    var baseName: String
    var selectedName: String
    var poweredUpName: String
    var poweredUpSelectedName: String
    var tripwireName: String
    
    //Status indicators
    var tripwireSprite: OverlaySprite?
    var moveDiagonalSprite: OverlaySprite?
    var jumpProofSprite: OverlaySprite?
    var inhibitedSprite: OverlaySprite?
    
    init(scene: GameScene, number: Int, team: Team, color: TorusColor, currentTile: Tile, size: CGSize) {
        
        self.torusNumber = number
        self.team = team
        self.torusColor = color
        self.currentTile = currentTile
        
        switch color {
        case .blue:
            baseName = TorusAsset.blueBase.rawValue
            selectedName = TorusAsset.blueSelected.rawValue
            poweredUpName = TorusAsset.bluePoweredUp.rawValue
            poweredUpSelectedName = TorusAsset.bluePoweredUpSelected.rawValue
            
            tripwireName = TorusOverlayAssets.tripwireBlue.rawValue
        default:
            baseName = TorusAsset.redBase.rawValue
            selectedName = TorusAsset.redSelected.rawValue
            poweredUpName = TorusAsset.redPoweredUp.rawValue
            poweredUpSelectedName = TorusAsset.redPoweredUpSelected.rawValue
            
            tripwireName = TorusOverlayAssets.tripwireRed.rawValue
        }
        
        let sprite = TorusSprite(textureName: baseName, size: CGSize(width: size.width, height: size.width))
        
        sprite.position = currentTile.boardPosition.getPoint()
        
        let name = "Torus - \(team.teamNumber) - \(torusNumber)"
        
        super.init(scene: scene, sprite: sprite, position: currentTile.boardPosition.point, spriteLevel: .torusOrScrollView, name: name, size: size)
        
        self.currentTile.occupy(with: self)
    }
    
    convenience init(scene: GameScene, tile: Tile, team: Team, size: CGSize, description: TorusDescription) {
        
        self.init(scene: scene, number: description.torusNumber, team: team, color: description.color, currentTile: tile, size: size)
        
        loadDescription(description: description)
    }
    
    //Touch interactions
    override func wasTouched() {
        
        manager.select(self)
        manager.select(self.currentTile)
    }
    
}

extension Torus {
    
    //Select
    func select() {
        
        sprite.texture = hasPowers ? SKTexture(imageNamed: poweredUpSelectedName) : SKTexture(imageNamed: selectedName)
        isSelected = true
    }
    
    func deselect() {

        sprite.texture = hasPowers ? SKTexture(imageNamed: poweredUpName) : SKTexture(imageNamed: baseName)
        isSelected = false
    }
    
    //Move
    
    func changeOccupancy(to newTile: Tile) {
        
        //Unoccupy current tile
        currentTile.unoccupy()
        
        //Occupy new tile
        currentTile = newTile
        currentTile.occupy(with: self)
    }
    
    func die() {
        
        currentTile.unoccupy()
        removeFromParent()
        team.remove(torus: self)
    }
    
    //Powers
    
    func powerUp(with power: PowerType) {
        
        powers[power] = (powers[power] ?? 0) + 1
        
        sprite.texture = SKTexture(imageNamed: poweredUpName)
    }
    
    func learn(_ powerSet: [PowerType:Int]) {
        print("learn powers")
        print(powerSet)
        
        for (power, powerCount) in powerSet {
            powers[power] = (powers[power] ?? 0) + powerCount
        }
        
        if !powerSet.isEmpty {
            sprite.texture = SKTexture(imageNamed: poweredUpName)
        } else {
            sprite.texture = SKTexture(imageNamed: baseName)
        }
    }
    
    func resetPowers() {
        print("reset")
        
        powers = [:]
        sprite.texture = SKTexture(imageNamed: baseName)
    }
}

extension Torus { // Change Status
    
    func tripwired() {
        
        activatedAttributes.isTripWired = true
        
        let texture = SKTexture(imageNamed: tripwireName)
        
        tripwireSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func moveDiagonal() {
        
        activatedAttributes.hasMoveDiagonal = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.moveDiagonal.rawValue)
        
        moveDiagonalSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func jumpProof() {
        
        activatedAttributes.hasJumpProof = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.jumpProof.rawValue)
        
        jumpProofSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func inhibited() {
        
        activatedAttributes.isInhibited = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.inhibited.rawValue)
        
        inhibitedSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
}

extension Torus { //Load Description
    
    func loadDescription(description: TorusDescription) {
        
        resetPowers()
        learn(description.powers)
        
        let attributes = description.attributes
        
        if attributes.hasClimbTile {
            //
        }
        if attributes.hasFlatToSphere {
            //
        }
        if attributes.hasInvisibility {
            //
        }
        if attributes.hasJumpProof {
            jumpProof()
        }
        if attributes.hasMoveDiagonal {
            moveDiagonal()
        }
        if attributes.isInhibited {
            inhibited()
        }
        if attributes.isSpyTapped {
            //
        }
        if attributes.isTripWired {
            tripwired()
        }
    }
    
}
