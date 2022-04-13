//
//  2 - Tray.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/12/21.
//

import Foundation
import SpriteKit

class Tray: Entity {

    var playScreen: PlayScreen
    
    var frame: CGRect {
        return playScreen.trayFrame
    }
    
    var redLabel: LabelSprite!
    var blueLabel: LabelSprite!
    
    var redLabelBackground: TrayItemSprite!
    var blueLabelBackground: TrayItemSprite!
    
    var redLabelTouched = false
    var blueLabelTouched = false
    
    var turnIndicator: OverlaySprite!
    
    var leftArea: OverlaySprite!
    var rightArea: OverlaySprite!
    
    var powerList: PowerList!
    
    init(scene: GameScene, playScreen: PlayScreen) {

        self.playScreen = playScreen
        
        let sprite = TraySprite(size: playScreen.trayFrame.size)
        
        super.init(scene: scene, sprite: sprite, position: CGPoint(x: playScreen.trayFrame.midX, y: playScreen.trayFrame.midY), spriteLevel: .boardOrTray, name: "Tray", size: playScreen.trayFrame.size)
        
        setUpLabels()
    }
    
    func setUpLabels() {
        
        //Assign left and right areas
        //Shrink sizes smaller than tray (0.3 instead of 0.33, 0.6 instead of 0.66, 0.9 instead of 1)
        
        let blank = SKTexture(imageNamed: "Blank")
        let leftSize = sprite.size.scaled(x: 0.2, y: 0.9)
        let rightSize = sprite.size.scaled(x: 0.75, y: 0.9)
        
        leftArea = OverlaySprite(primaryTexture: blank, color: UIColor.clear, blend: true, size: leftSize, parentSprite: sprite)
        rightArea = OverlaySprite(primaryTexture: blank, color: UIColor.clear, blend: true, size: rightSize, parentSprite: sprite)
        

        leftArea.position = CGPoint(x: (-sprite.size.width * 0.7)/2, y: 0)
        rightArea.position = CGPoint(x: (sprite.size.width * 0.2)/2, y: 0)
        
        
        //Labels and label background
        let labelSize = CGSize(width: leftArea.size.height / 3, height: leftArea.size.height / 3)
        let labelY = leftArea.size.height / 4
        
        redLabelBackground = TrayItemSprite(primaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.redHighlighted.rawValue), secondaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.redUnhighlighted.rawValue), color: UIColor.clear, size: labelSize, parentSprite: leftArea) {
            self.redLabelTouched = true
            self.debugActivated()
        }
        blueLabelBackground = TrayItemSprite(primaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.blueUnhighlighted.rawValue), secondaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.blueHighlighted.rawValue), color: UIColor.clear, size: labelSize, parentSprite: leftArea){
            self.blueLabelTouched = true
            self.debugActivated()
        }
        
        redLabelBackground.position = CGPoint(x: 0, y: labelY)
        blueLabelBackground.position = CGPoint(x: 0, y: -labelY)
        
        redLabel = LabelSprite(parentSprite: redLabelBackground) {
            self.redLabelTouched = true
            self.debugActivated()
        }
        blueLabel = LabelSprite(parentSprite: blueLabelBackground) {
            self.blueLabelTouched = true
            self.debugActivated()
        }
        
        redLabel.fontSize = 24
        blueLabel.fontSize = 24
        
        // Text Area
        let textBoxSize = rightSize.scaled(by: 0.9)
        powerList = PowerList(scene: scene, position: self.position.move(.right, by: redLabelBackground.size.width), size: textBoxSize)
    }
    
    func resetTouches() {
        redLabelTouched = false
        blueLabelTouched = false
    }
    
    func debugActivated() {
        print("Activate debug")
        print(redLabelTouched, blueLabelTouched)
        if redLabelTouched && blueLabelTouched {
            if let tile = manager.lastTile {
                var description = ""
                description += "Tile - " + tile.boardPosition.name
                description += " Status - " + tile.status.rawValue
                description += " Has Orb - " + String(tile.hasOrb)
                let tileNode = TextNode(description, size: self.sprite.size)
                tileNode.zPosition = SpriteLevel.label.rawValue
                tileNode.position = CGPoint(x: 10, y: 50)
                tileNode.label.numberOfLines = 0
                tileNode.label.lineBreakMode = .byWordWrapping
                tileNode.label.preferredMaxLayoutWidth = self.sprite.size.width
                tileNode.label.fontName = "Courier - Bold"
                scene.addChild(tileNode)
                
                scene.run(SKAction.wait(forDuration: 2)) {
                    tileNode.removeFromParent()
                }
            }
            
            if let torus = manager.lastTorus {
                
                var description = ""
                description += torus.name + "\n"
                description += torus.powers.description + "\n"
                description += torus.activatedAttributes.description
                
                print(description)
                let torusNode = TextNode(description, size: self.sprite.size)
                torusNode.zPosition = SpriteLevel.label.rawValue
                torusNode.position = CGPoint(x: 10, y: scene.size.height / 2)
                torusNode.label.numberOfLines = 0
                torusNode.label.lineBreakMode = .byWordWrapping
                torusNode.label.preferredMaxLayoutWidth = self.sprite.size.width
                torusNode.label.fontName = "Courier - Bold"
                scene.addChild(torusNode)
                
                scene.run(SKAction.wait(forDuration: 2)) {
                    torusNode.removeFromParent()
                }
            }
        }
    }
}
