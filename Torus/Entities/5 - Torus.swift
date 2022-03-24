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
    unowned var team: Team
    
    var powers = [PowerType:Int]() {
        didSet {
            if powers.isEmpty {
                sprite.texture = SKTexture(imageNamed: baseName)
                //if !ChangeDecoder.helper.currentlyDecoding { ChangeManager.register.removePowers(for: self) }
            } else {
                sprite.texture = SKTexture(imageNamed: poweredUpName)
                //if oldValue == powers { print("No Change") }
                //if !ChangeDecoder.helper.currentlyDecoding { ChangeManager.register.addPower(for: self) }
            }
        }
    }
    var activatedAttributes = ActivatedAttributes()
    
    unowned var currentTile: Tile
    
    var isSelected = false
    
    var hasPowers: Bool { return !powers.isEmpty }
    
    //Sprite Names
    var baseName: String
    var selectedName: String
    var poweredUpName: String
    var poweredUpSelectedName: String
    var tripwireName: String
    
    //Status indicators
    var climbTileSprite: OverlaySprite?
    var tripwireSprite: OverlaySprite?
    var moveDiagonalSprite: OverlaySprite?
    var jumpProofSprite: OverlaySprite?
    var inhibitedSprite: OverlaySprite?
    var flatToSphereSprite: OverlaySprite?
    var invisibleSprite: OverlaySprite?
    
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
        
        //TESTING
        if TestingManager.helper.toriiStartWithPowers {
            
            if torusNumber % 2 == 0 { return }
            for _ in 0 ... Int.random(in: 0 ... 3) {
                //self.powerUp(with: PowerType.random())
                //self.powerUp(with: PowerType(.jumpProof))
                //self.powerUp(with: PowerType(.tripwire, .column))
                //self.powerUp(with: PowerType(.purify, .column))
                //self.powerUp(with: PowerType(.relocate))
                //self.powerUp(with: PowerType(.doublePowers))
                //self.powerUp(with: PowerType(.recruit, .column))
                //self.powerUp(with: PowerType(.swap, .column))
                //self.powerUp(with: PowerType(.learn, .column))
                //self.powerUp(with: PowerType(.snakeTunnelling, .column))
                //self.powerUp(with: PowerType(.wall, .column))
                //self.powerUp(with: PowerType(.trench, .column))
                //self.powerUp(with: PowerType(.raiseTile))
                //self.powerUp(with: PowerType(.lowerTile))
                
                self.powerUp(with: PowerType(.moat, .column))
                self.powerUp(with: PowerType(.moat, .row))
                self.powerUp(with: PowerType(.invert, .row))
                self.powerUp(with: PowerType(.invert, .column))
                self.powerUp(with: PowerType(.respawnOrbs))
                self.powerUp(with: PowerType(.beneficiary))
                self.powerUp(with: PowerType(.kamikaze, .row))
                self.powerUp(with: PowerType(.kamikaze, .column))
                self.powerUp(with: PowerType(.scramble, .row))
                self.powerUp(with: PowerType(.scramble, .column))
                self.powerUp(with: PowerType(.scramble, .radius))
            }
        }
    }
    
    convenience init(scene: GameScene, tile: Tile, team: Team, size: CGSize, description: TorusDescription) {
        
        self.init(scene: scene, number: description.torusNumber, team: team, color: description.color, currentTile: tile, size: size)
        
        loadDescription(description: description)
    }
    
    //Touch interactions
    override func wasTouched() {
        
        manager.select(self, triggeredBy: "Torus was touched")
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
        if self.name == manager.currentTeam.currentlySelected?.name {
            manager.deselectCurrent()
        }
    }
    
    //Powers
    
    func learn(_ powerSet: [PowerType:Int]) -> Bool {
        
        var exceeds20 = false
        
        for (power, powerCount) in powerSet {
            powers[power] = (powers[power] ?? 0) + powerCount
            if powers[power]! > 20 { exceeds20 = true }
        }

        if exceeds20 {
            manager.powerList.displayPowerConsole(message: .powerConsoleOverHeat)
            AnimationManager.helper.kill(torus: self, deathType: .acidic) {}
        }
        
        return exceeds20
    }
    
    func powerUp(with power: PowerType) -> Bool {
        
        powers[power] = (powers[power] ?? 0) + 1
        
        var exceeds20 = false
        
        powers.forEach { if $0.value > 20 { exceeds20 = true} }
        
        if exceeds20 {
            manager.powerList.displayPowerConsole(message: .powerConsoleOverHeat)
            AnimationManager.helper.kill(torus: self, deathType: .acidic) {}
        }
        return exceeds20
    }
    
    func purify(isEnemy: Bool) -> Bool {
        
        var wasEffective = false
        
        print("Purify \(self.name) - isEnemy is \(isEnemy)")
        
        if isEnemy {

            if let climbTile = climbTileSprite {
                activatedAttributes.hasClimbTile = false
                climbTile.removeFromParent()
                climbTileSprite = nil
                wasEffective = true
            }
            
            if let jumpProof = jumpProofSprite {
                activatedAttributes.hasJumpProof = false
                jumpProof.removeFromParent()
                jumpProofSprite = nil
                wasEffective = true
            }
            
            if let moveDiagonal = moveDiagonalSprite {
                activatedAttributes.hasMoveDiagonal = false
                moveDiagonal.removeFromParent()
                moveDiagonalSprite = nil
                wasEffective = true
            }
            
            if let flatToSphere = flatToSphereSprite {
                activatedAttributes.hasFlatToSphere = false
                flatToSphere.removeFromParent()
                flatToSphereSprite = nil
                wasEffective = true
            }
            
            if let invisible = invisibleSprite {
                activatedAttributes.hasInvisibility = false
                invisible.removeFromParent()
                invisibleSprite = nil
                wasEffective = true
            }
        } else {

            if let inhibited = inhibitedSprite {
                activatedAttributes.isInhibited = false
                inhibited.removeFromParent()
                inhibitedSprite = nil
                wasEffective = true
            }
            
            if let tripWire = tripwireSprite {
                activatedAttributes.isTripWired = false
                tripWire.removeFromParent()
                tripwireSprite = nil
                wasEffective = true
            }
        }
        
        return wasEffective
    }
    
    func resetPowers() {
        
        powers = [:]
    }
}

extension Torus { // Change Status
    
    //GOOD STUFF
    func climbTile() {
        
        //SPECIAL
        AnimationManager.helper.climbTileAnimation(for: self)
        
        activatedAttributes.hasClimbTile = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.climbTile.rawValue)
        
        climbTileSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func flatToSphere() {
        
        activatedAttributes.hasFlatToSphere = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.flatToSphere.rawValue)
        
        flatToSphereSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func invisible() {
        
        activatedAttributes.hasInvisibility = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.invisible.rawValue)
        
        invisibleSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func jumpProof() {
        
        activatedAttributes.hasJumpProof = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.jumpProof.rawValue)
        
        jumpProofSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func moveDiagonal() {
        
        activatedAttributes.hasMoveDiagonal = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.moveDiagonal.rawValue)
        
        moveDiagonalSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    // BAD STUFF
    func inhibited() {
        
        activatedAttributes.isInhibited = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.inhibited.rawValue)
        
        inhibitedSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
    
    func tripwired() {
        
        activatedAttributes.isTripWired = true
        
        let texture = SKTexture(imageNamed: tripwireName)
        
        tripwireSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
    }
}

extension Torus { //Load Description
    
    func loadDescription(description: TorusDescription) {

        self.powers = description.powers
        
        let attributes = description.attributes
        
        if attributes.hasClimbTile {
            climbTile()
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

extension Torus: CustomStringConvertible {
    var description: String {
        var description = name
        description += activatedAttributes.description
        return description
    }
}
