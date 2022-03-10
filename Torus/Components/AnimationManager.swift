//
//  AnimationManager.swift
//  Triple Bomb
//
//  Created by Moses Harding on 11/15/21.
//

import SpriteKit

class AnimationManager {
    
    static let helper = AnimationManager()
    
    var scene: GameScene!

    var isFirstTurn = true
}

extension AnimationManager { //Torus
    
    func move(torus: Torus, to newTile: Tile, completion: @escaping () -> ()) {
        
        let moveToAction = SKAction.move(to: torus.currentTile.boardPosition.getPoint(), duration: 0.2)
        torus.sprite.run(moveToAction) { completion() }
    }
    
    func attack(torus: Torus, to newTile: Tile, against opponent: Torus, completion: @escaping () -> ()) {
        
        let moveToAction = SKAction.move(to: torus.currentTile.boardPosition.getPoint(), duration: 0.2)
        let grow = SKAction.scale(to: 1.75, duration: 0.125)
        let shrink = SKAction.scale(to: 1, duration: 0.1)
        let growAndShrink = SKAction.sequence([grow,shrink])
        let attackGroup = SKAction.group([growAndShrink, moveToAction])
        
        torus.sprite.zPosition += 1
        torus.sprite.run(attackGroup) {
            self.kill(torus: opponent, deathType: .normal, completion: { torus.sprite.zPosition -= 1 })
            completion()
        }
    }
    
    func takeOrb(torus: Torus, to newTile: Tile, completion: @escaping () -> ()) {
        
        let moveToDuration = 0.2
        let growDuration = 0.125
        let shrinkDuration = 0.075
        let totalDuration = moveToDuration + growDuration + shrinkDuration
        
        let moveToAction = SKAction.move(to: torus.currentTile.boardPosition.getPoint(), duration: moveToDuration)
        let grow = SKAction.scale(to: 1.5, duration: growDuration)
        let shrink = SKAction.scale(to: 1, duration: shrinkDuration)
        let growAndShrink = SKAction.sequence([grow,shrink])
        let attackGroup = SKAction.group([growAndShrink, moveToAction])
        
        torus.sprite.zPosition = SpriteLevel.tileOverlay.rawValue + 2
        
        torus.sprite.run(attackGroup) {
            newTile.removeOrb(duration: totalDuration, completion: { torus.sprite.zPosition = SpriteLevel.torusOrScrollView.rawValue })
            PowerManager.helper.assignPower(to: torus)
            completion()
        }
    }

    //Die
    func kill(torus: Torus, deathType: DeathType, completion: @escaping (() -> ()) ) {
        
        var animationGroup: SKAction
        
        switch deathType {
        case .acidic:
            let moveUp = SKAction.moveBy(x: 0, y: CGFloat.random(in: 5 ... 15), duration: CGFloat.random(in: 0.025 ... 0.075))
            let moveDown = SKAction.moveBy(x: 0, y: CGFloat.random(in: -15 ... -5), duration: CGFloat.random(in: 0.025 ... 0.075))
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let movingSequence = SKAction.sequence( [moveUp, moveDown, moveUp, moveDown, moveUp, moveDown, fadeOut])
            
            let flashIn = SKAction.colorize(with: .systemRed, colorBlendFactor: 1, duration: CGFloat.random(in: 0.025 ... 0.075))
            let flashOut = SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: CGFloat.random(in: 0.025 ... 0.075))
            let flashingSequence = SKAction.sequence( [flashIn, flashOut, flashIn, flashOut, flashIn, flashOut])
            
            animationGroup = SKAction.group([movingSequence, flashingSequence])
        case .destroy:
            let moveUp = SKAction.moveBy(x: 0, y: CGFloat.random(in: 5 ... 15), duration: CGFloat.random(in: 0.025 ... 0.075))
            let moveDown = SKAction.moveBy(x: 0, y: CGFloat.random(in: -15 ... -5), duration: CGFloat.random(in: 0.025 ... 0.075))
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            animationGroup = SKAction.sequence( [moveUp, moveDown, moveUp, moveDown, moveUp, moveDown, fadeOut])
        case .normal:
            animationGroup = SKAction.resize(toWidth: 0, height: 0, duration: 0.1)
        case .tripwire:
            animationGroup = SKAction.group( [SKAction.rotate(byAngle: 5, duration: 0.4), SKAction.fadeOut(withDuration: 0.4)] )
        }
        
        torus.sprite.run(animationGroup) {
            completion()
            torus.die()
        }
    }
}

extension AnimationManager { //Tile
    
    func populateOrb(_ tile: Tile) {
        
        tile.orbOverlay = OrbOverlay(parentSize: tile.sprite.size, parentSprite: tile.sprite)
        tile.orbOverlay?.position = CGPoint(x: CGFloat(tile.height.rawValue * 2), y: CGFloat(tile.height.rawValue * 2))
        
        if let orb = tile.orbOverlay {
            
            let fadeInTime = CGFloat.random(in: 0.05 ... 0.2)
            let fadeOutTime = CGFloat.random(in: 0.05 ... 0.2)
            
            let flickerIn = SKAction.fadeIn(withDuration: fadeInTime)
            let flickerOut = SKAction.fadeOut(withDuration: fadeOutTime)
            
            let fadeGroup = SKAction.sequence([flickerOut, flickerIn, flickerOut, flickerIn])
            
            orb.run(fadeGroup)
        }
    }
}

extension AnimationManager { //Powers
    
    func pilferPowers(from torus: Torus) {
        
        let fade = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        
        torus.sprite.run(fade) {
            torus.resetPowers()
            torus.sprite.run(fadeIn)
        }
        
        //ChangeManager.register.syncPowers(for: torus)
    }
}
