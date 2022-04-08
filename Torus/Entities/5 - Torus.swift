//
//  Torus.swift
//  Torus Neon
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
            } else {
                sprite.texture = SKTexture(imageNamed: poweredUpName)
            }
        }
    }
    var activatedAttributes = ActivatedAttributes()
    
    unowned var currentTile: Tile
    
    var isSelected = false
    
    var hasPowers: Bool { return !powers.isEmpty }
    
    var verbose = true
    
    var leaping = false
    
    //Sprite Names
    var baseName: String
    var selectedName: String
    var poweredUpName: String
    var poweredUpSelectedName: String
    
    //Status indicators
    var amplifySprite: OverlaySprite?
    var weightlessSprite: OverlaySprite?
    var armorSprite: OverlaySprite?
    var freeMovementSprite: OverlaySprite?
    var snareSprite: OverlaySprite?
    
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
        default:
            baseName = TorusAsset.redBase.rawValue
            selectedName = TorusAsset.redSelected.rawValue
            poweredUpName = TorusAsset.redPoweredUp.rawValue
            poweredUpSelectedName = TorusAsset.redPoweredUpSelected.rawValue
        }
        
        let sprite = TorusSprite(textureName: baseName, size: CGSize(width: size.width, height: size.width))
        let name = "Torus - \(team.teamNumber) - \(torusNumber)"
        
        super.init(scene: scene, sprite: sprite, position: currentTile.boardPosition.point, spriteLevel: .torusOrScrollView, name: name, size: size)
        
        self.currentTile.occupy(with: self)
        
        sprite.position = currentTile.boardPosition.getPoint()
        
        //TESTING
        if TestingManager.helper.toriiStartWithPowers {
            for _ in 0 ... Int.random(in: 0 ... 3) { self.powerUp(with: PowerType.random()) }
            /*
            let allPowers = Power.allCases
            for power in allPowers {
                self.powerUp(with: power, .column)
                self.powerUp(with: power, .row)
            }
             */
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
    
    func die(calledBy: String) {
        
        if verbose { print("\(self.name) has died, called by \(calledBy)") }
        
        if currentTile.occupiedBy == self {
            currentTile.unoccupy()
        }
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
            manager.powerList.displayPowerConsole(message: .powerConsoleOverHeat, calledBy: "Torus - Learn - OverHeat")
            AnimationManager.helper.kill(torus: self, deathType: .disintegrate, calledBy: "Learn - Overheat") {}
        }
        
        return exceeds20
    }
    
    @discardableResult
    func powerUp(with power: PowerType) -> Bool {
        
        powers[power] = (powers[power] ?? 0) + 1
        
        var exceeds20 = false
        
        powers.forEach { if $0.value > 20 { exceeds20 = true} }
        
        if exceeds20 {
            manager.powerList.displayPowerConsole(message: .powerConsoleOverHeat, calledBy: "Torus - PowerUp - OverHeat")
            AnimationManager.helper.kill(torus: self, deathType: .disintegrate, calledBy: "Power Up - Overheat") {}
        }
        return exceeds20
    }

    @discardableResult
    func powerUp(with powerType: Power, _ direction: PowerDirection? = nil) -> Bool {
        
        let power = PowerType(powerType, direction)
        
        powers[power] = (powers[power] ?? 0) + 1
        
        var exceeds20 = false
        
        powers.forEach { if $0.value > 20 { exceeds20 = true} }
        
        if exceeds20 {
            manager.powerList.displayPowerConsole(message: .powerConsoleOverHeat, calledBy: "Torus - Power Up - OverHeat")
            AnimationManager.helper.kill(torus: self, deathType: .disintegrate, calledBy: "Power Up - Overheat") {}
        }
        return exceeds20
    }
    
    func cleanse(isEnemy: Bool) -> Bool {
        
        var wasEffective = false
        
        if isEnemy {
            
            if let amplify = amplifySprite {
                activatedAttributes.hasAmplify = false
                amplify.removeFromParent()
                amplifySprite = nil
                wasEffective = true
            }

            if let weightless = weightlessSprite {
                activatedAttributes.hasWeightless = false
                weightless.removeFromParent()
                weightlessSprite = nil
                wasEffective = true
            }
            
            if let armor = armorSprite {
                activatedAttributes.hasArmor = false
                armor.removeFromParent()
                armorSprite = nil
                wasEffective = true
            }
            
            if let freeMove = freeMovementSprite {
                activatedAttributes.hasFreeMovement = false
                freeMove.removeFromParent()
                freeMovementSprite = nil
                wasEffective = true
            }
        } else {
            
            if let snare = snareSprite {
                activatedAttributes.isSnared = false
                snare.removeFromParent()
                snareSprite = nil
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
    func amplify() {
        
        activatedAttributes.hasAmplify = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.amplify.rawValue)
        
        amplifySprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
        amplifySprite?.zPosition = TorusOverlaySpriteLevel.amplify.rawValue
    }
    
    func weightless() {
        
        //SPECIAL
        AnimationManager.helper.weightlessAnimation(for: self)
        
        activatedAttributes.hasWeightless = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.weightless.rawValue)
        
        weightlessSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
        weightlessSprite?.zPosition = TorusOverlaySpriteLevel.weightless.rawValue
    }
    
    func armor() {
        
        activatedAttributes.hasArmor = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.armor.rawValue)
        
        armorSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
        armorSprite?.zPosition = TorusOverlaySpriteLevel.armor.rawValue
    }
    
    func freeMovement() {
        
        activatedAttributes.hasFreeMovement = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.freeMovement.rawValue)
        
        freeMovementSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
        freeMovementSprite?.zPosition = TorusOverlaySpriteLevel.freeMovement.rawValue
    }
    
    // BAD STUFF
    func snared() {
        
        activatedAttributes.isSnared = true
        
        let texture = SKTexture(imageNamed: TorusOverlayAssets.snare.rawValue)
        
        snareSprite = OverlaySprite(primaryTexture: texture, color: UIColor.white, size: sprite.size, parentSprite: sprite)
        snareSprite?.zPosition = TorusOverlaySpriteLevel.snare.rawValue
    }
}

extension Torus { //Load Description
    
    func loadDescription(description: TorusDescription) {

        self.powers = description.powers
        
        let attributes = description.attributes
        
        if attributes.hasAmplify {
            amplify()
        }
        if attributes.hasWeightless {
            weightless()
        }
        if attributes.hasArmor {
            armor()
        }
        if attributes.hasFreeMovement {
            freeMovement()
        }
        if attributes.isSnared {
            snared()
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

extension Torus: Equatable {
    static func == (lhs: Torus, rhs: Torus) -> Bool {
        return lhs.name == rhs.name
    }
}
