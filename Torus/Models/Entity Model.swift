//
//  Entity.swift
//  Torus Neon
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit


class Entity {
    
    unowned var scene: GameScene
    
    var manager: GameManager {
        return scene.gameManager
    }
    
    var sprite: EntitySprite!
    
    var name: String
    
    var position: CGPoint
    var spriteLevel: SpriteLevel
    var size: CGSize
    
    init(scene: GameScene, sprite: EntitySprite, position: CGPoint, spriteLevel: SpriteLevel, name: String, size: CGSize) {
        
        self.scene = scene
        self.sprite = sprite
        self.spriteLevel = spriteLevel
        self.size = size
        self.position = position
        self.name = name

        addToParent()
    }
    
    func addToParent() {
        sprite.position = position
        sprite.zPosition = spriteLevel.rawValue
        sprite.parentEntity = self
        scene.addChild(sprite)
    }
    
    func removeFromParent() {
        self.sprite.removeFromParent()
    }
    
    func wasTouched() {
        print(name + " entity was touched.")
    }
}
