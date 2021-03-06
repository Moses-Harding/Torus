//
//  AnimationManager.swift
//  Torus Neon
//
//  Created by Moses Harding on 11/15/21.
// 

import SpriteKit

class AnimationManager {
    
    static let helper = AnimationManager()
    
    var scene: GameScene!
    
    var timer: Timer?
    
    var isFirstTurn = true
}

extension AnimationManager {
    
    func attack(torus: Torus, to newTile: Tile, against opponent: Torus, completion: @escaping () -> ()) -> CGFloat {
        
        let waitDuration = 2.25
        
        let moveToAction = SKAction.move(to: torus.currentTile.boardPosition.getPoint(), duration: 0.2)
        let grow = SKAction.scale(to: 1.75, duration: 0.125)
        let shrink = SKAction.scale(to: 1, duration: 0.1)
        let growAndShrink = SKAction.sequence([grow,shrink])
        let attackGroup = SKAction.group([growAndShrink, moveToAction])
        
        torus.sprite.zPosition += 1
        torus.sprite.run(attackGroup) {
            self.kill(torus: opponent, deathType: .normal, calledBy: "Attack", completion: { torus.sprite.zPosition -= 1 } )
            completion()
        }
        
        return waitDuration
    }
    
    func missile(tile: Tile) {
        
        let missileSprite = SKSpriteNode(imageNamed: "Missile")
        missileSprite.size = tile.size.scaled(by: 0.95)
        tile.sprite.addChild(missileSprite)
        missileSprite.zPosition = tile.sprite.zPosition + 1
        
        let shrink = SKAction.scale(to: 0.5, duration: 0.2)
        
        if let torus = tile.occupiedBy {
            missileSprite.run(shrink) {
                tile.missileStrike()
                missileSprite.removeFromParent()
            }
            self.kill(torus: torus, deathType: .disintegrate, calledBy: "Missile") {}
        } else {
            missileSprite.run(shrink) {
                tile.missileStrike()
                missileSprite.removeFromParent()
            }
        }
    }
    
    @discardableResult
    func kill(torus: Torus, deathType: DeathType, calledBy: String, completion: @escaping (() -> ()) ) -> CGFloat {
        
        var animationGroup: SKAction
        
        var duration: CGFloat = 0
        
        switch deathType {
        case .disintegrate:
            let upDuration = CGFloat.random(in: 0.025 ... 0.075)
            let downDuration = CGFloat.random(in: 0.025 ... 0.075)
            let fadeDuration = 0.1
            let flashInDuration = CGFloat.random(in: 0.025 ... 0.075)
            let flashOutDuration = CGFloat.random(in: 0.025 ... 0.075)
            
            let seq1 = (upDuration * 3) + (downDuration * 3) + fadeDuration
            let seq2 = (flashInDuration * 3) + (flashOutDuration * 3)
            duration = seq1 > seq2 ? seq1 : seq2
            
            let moveUp = SKAction.moveBy(x: 0, y: CGFloat.random(in: 5 ... 15), duration: upDuration)
            let moveDown = SKAction.moveBy(x: 0, y: CGFloat.random(in: -15 ... -5), duration: downDuration)
            let fadeOut = SKAction.fadeOut(withDuration: fadeDuration)
            let movingSequence = SKAction.sequence( [moveUp, moveDown, moveUp, moveDown, moveUp, moveDown, fadeOut])
            
            let flashIn = SKAction.colorize(with: .systemRed, colorBlendFactor: 1, duration: flashInDuration)
            let flashOut = SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: flashOutDuration)
            let flashingSequence = SKAction.sequence( [flashIn, flashOut, flashIn, flashOut, flashIn, flashOut])
            
            animationGroup = SKAction.group([movingSequence, flashingSequence])
        case .obliterate:
            let upDuration = CGFloat.random(in: 0.025 ... 0.075)
            let downDuration = CGFloat.random(in: 0.025 ... 0.075)
            let fadeDuration = 0.1
            
            duration = (upDuration * 3) + (downDuration * 3) + fadeDuration
            
            let moveUp = SKAction.moveBy(x: 0, y: CGFloat.random(in: 5 ... 15), duration: upDuration)
            let moveDown = SKAction.moveBy(x: 0, y: CGFloat.random(in: -15 ... -5), duration: downDuration)
            let fadeOut = SKAction.fadeOut(withDuration: fadeDuration)
            
            animationGroup = SKAction.sequence( [moveUp, moveDown, moveUp, moveDown, moveUp, moveDown, fadeOut])
        case .fadeOut:
            duration = 0.5
            
            animationGroup = SKAction.group([SKAction.fadeOut(withDuration: duration), SKAction.scale(to: 1.2, duration: duration)])
        case .normal:
            duration = 0.1
            
            animationGroup = SKAction.resize(toWidth: 0, height: 0, duration: 0.1)
        case .snare:
            duration = 0.4
            
            let slowSpin = SKAction.rotate(byAngle: 4, duration: 0.5)
            let slowShrink = SKAction.resize(toWidth: torus.size.width / 2, height: torus.size.height / 2, duration: 0.5)
            
            let fastSpin = SKAction.rotate(byAngle: 5, duration: 0.4)
                            let fastShrink = SKAction.resize(toWidth: 0, height: 0, duration: 0.4)
            
            let group1 = SKAction.group([slowSpin, slowShrink])
            let group2 = SKAction.group([fastSpin, fastShrink])
                            
            
            animationGroup = SKAction.sequence([group1, group2])

        }
        
        torus.sprite.run(animationGroup) {
            torus.die(calledBy: "Kill - \(calledBy)")
            completion()
        }
        
        return duration
    }
    
    func move(torus: Torus, to newTile: Tile, completion: @escaping () -> ()) -> CGFloat {
        
        let waitDuration =  0.25
        
        let moveToAction = SKAction.move(to: torus.currentTile.boardPosition.getPoint(), duration: 0.2)
        let grow = SKAction.scale(to: 1.75, duration: 0.125)
        let shrink = SKAction.scale(to: 1, duration: 0.1)
        let growAndShrink = SKAction.sequence([grow,shrink])
        let attackGroup = SKAction.group([growAndShrink, moveToAction])
        
        torus.sprite.run(attackGroup) {
            completion()
        }
        
        return waitDuration
    }
    
    func defect(torus: Torus) -> CGFloat {
        
        guard let manager = scene?.gameManager else { fatalError("AnimationManager - Defect - GameManager Not Found") }
        
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
        
        let left = SKAction.move(by: CGVector(dx: 3, dy: 0), duration: 0.05)
        let right = SKAction.move(by: CGVector(dx: -3, dy: 0), duration: 0.05)
        
        let shake = SKAction.sequence([left, right, left, right, left, right, left, right])
        
        let defectGroup = SKAction.group([fadeOut, shake])
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        
        torus.sprite.run(defectGroup) {
            let torusCopy = torus
            torus.die(calledBy: "Defect")
            guard let oppositeTeam = torus.team.teamNumber == .one ? manager.team2 : manager.team1 else { fatalError("AnimationManager  - Defect - Opposite Team Not Found") }
            let newTorus = oppositeTeam.addTorus(from: torusCopy)
            newTorus.sprite.run(fadeIn)
        }
        
        return 0.5
    }
    
    func float(torus: Torus, to newTile: Tile, absoluteDistance: Int, takeOrb: Bool = false, completion: @escaping () -> ()) -> CGFloat {
        
        let waitDuration: CGFloat = CGFloat(absoluteDistance) * 0.5
        
        let moveToAction = SKAction.move(to: torus.currentTile.boardPosition.getPoint(), duration: waitDuration)
        let grow = SKAction.scale(to: 1.5, duration: (waitDuration / 10))
        let wait = SKAction.wait(forDuration: (waitDuration / 10) * 8)
        let shrink = SKAction.scale(to: 1, duration: (waitDuration / 10))
        let growAndShrink = SKAction.sequence([grow, wait, shrink])
        let floatGroup = SKAction.group([growAndShrink, moveToAction])
        
        torus.sprite.zPosition += 1
        torus.sprite.run(floatGroup)

        
        torus.sprite.run(floatGroup) {
            if takeOrb {
                guard let power = newTile.nextPower else { fatalError("TakeOrb - No power to assign to torus") }
                newTile.removeOrb { torus.sprite.zPosition = SpriteLevel.torusOrScrollView.rawValue }
                PowerManager.helper.assign(power: power, to: torus)
            }
        }
        
        return waitDuration
    }
    
    func shuffle(torus: Torus, to newTile: Tile, takeOrb: Bool = false) -> CGFloat {
        
        var waitDuration = 0.5
        
        let capturedTorus = torus
    
        let fadeIn = SKAction.fadeIn(withDuration: waitDuration)
        let grow = SKAction.scale(to: 1.2, duration: 0)
        let shrink = SKAction.scale(to: 1, duration: waitDuration)
        
        let newTorus = capturedTorus.team.addTorus(from: torus, override: newTile.boardPosition, keepNumber: true)
        newTorus.sprite.alpha = 0
        newTorus.sprite.run(grow)
        
        let shuffleAnimationGroup = SKAction.group([fadeIn, shrink])
        

        newTorus.sprite.run(shuffleAnimationGroup) {
            if takeOrb {
                guard let power = newTile.nextPower else { fatalError("AnimationManager - Shuffle - TakeOrb - No power to assign to torus") }
                newTile.removeOrb { newTorus.sprite.zPosition = SpriteLevel.torusOrScrollView.rawValue }
                PowerManager.helper.assign(power: power, to: newTorus)
            }
            if newTorus.activatedAttributes.isSnared {
                self.kill(torus: newTorus, deathType: .snare, calledBy: "Shuffle - Snare", completion: {} )
                waitDuration = 1
            }
        }
        
        return waitDuration
    } 
    
    
    func takeOrb(torus: Torus, to newTile: Tile, completion: @escaping () -> ()) -> CGFloat {
        
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
        
        guard let power = newTile.nextPower else { fatalError("TakeOrb - No power to assign to torus") }
        
        torus.sprite.run(attackGroup) {
            newTile.removeOrb { torus.sprite.zPosition = SpriteLevel.torusOrScrollView.rawValue }
            PowerManager.helper.assign(power: power, to: torus)
            completion()
        }
        
        return totalDuration
    }
    
    func finalAnimation() {

        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [self] timer in
            createColorSprite()
        }
    }
    
    func createColorSprite() {
        let colors  = UIColor.convertSCSS("$flickr-pink: rgba(247, 37, 133, 1);$byzantine: rgba(181, 23, 158, 1);$purple: rgba(114, 9, 183, 1);$purple-2: rgba(86, 11, 173, 1);$trypan-blue: rgba(72, 12, 168, 1);$trypan-blue-2: rgba(58, 12, 163, 1);$persian-blue: rgba(63, 55, 201, 1);$ultramarine-blue: rgba(67, 97, 238, 1);$dodger-blue: rgba(72, 149, 239, 1);$vivid-sky-blue: rgba(76, 201, 240, 1);")
        let sprites = ["S1", "S2", "S3", "S4", "S5", "S6"]
        
        let spriteName = sprites.randomElement() ?? "S1"
        let color = colors.randomElement() ?? UIColor.systemPink
        let sprite = SKSpriteNode(imageNamed: spriteName)
        sprite.color = color
        sprite.colorBlendFactor = 1
        
        let randomX = CGFloat.random(in: 0 ... scene.frame.width)
        
        let randomPoint = CGPoint(x: randomX, y: -50)
        sprite.position = randomPoint
        sprite.size.scale(proportionateTo: .width, with: scene.frame.width / 3)
        
        scene.addChild(sprite)
        
        sprite.zPosition = scene.playScreen.buttonTray.backButton.zPosition - 1
        
        let move = SKAction.move(to: CGPoint(x: CGFloat.random(in: 0 ... scene.frame.width), y: scene.frame.height + sprite.size.height), duration: 4)
        let rotate = SKAction.rotate(byAngle: CGFloat.random(in: 0 ... 5), duration: 4)
        sprite.run(SKAction.group([move, rotate]))
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
    
    func weightlessAnimation(for torus: Torus) {
        let grow = SKAction.scale(to: 1.2, duration: 0.3)
        let shrink = SKAction.scale(to: 1, duration: 0.3)
        let group = SKAction.sequence([grow, shrink])
        torus.sprite.run(group)
    }
    
    func leechPowers(from torus: Torus) -> CGFloat {
        
        let fade = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        
        torus.sprite.run(fade) {
            torus.resetPowers()
            torus.sprite.run(fadeIn)
        }
        
        return 0.3
    }
    
    func cleanse(_ torus: Torus, isEnemy: Bool) -> (CGFloat, Bool) {
        
        var waitDuration: CGFloat = 0
        
        let fade = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        var wasEffective = false
        
        wasEffective = torus.cleanse(isEnemy: isEnemy)
        
        if wasEffective {
            torus.sprite.run(fade) {
                torus.sprite.run(fadeIn)
            }
            waitDuration = 0.3
        }
        
        return (waitDuration, wasEffective)
    }
}
