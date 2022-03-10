//
//  2 - Tray.swift
//  Triple Bomb
//
//  Created by Moses Harding on 10/12/21.
//

import Foundation
import SpriteKit

class ButtonTray: Entity {

    var playScreen: PlayScreen
    
    var frame: CGRect {
        return playScreen.trayFrame
    }

    var backButton: TouchNode!
    
    var leftArea: OverlaySprite!
    var rightArea: OverlaySprite!
    
    init(scene: GameScene, playScreen: PlayScreen) {

        self.playScreen = playScreen
        
        let sprite = ButtonTraySprite(size: playScreen.buttonTrayFrame.size)
        
        super.init(scene: scene, sprite: sprite, position: CGPoint(x: playScreen.buttonTrayFrame.midX, y: playScreen.buttonTrayFrame.midY), spriteLevel: .boardOrTray, name: "Button Tray", size: playScreen.buttonTrayFrame.size)
        
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
        
        backButton = TouchNode("Back", size: leftSize.scaled(by: 0.8)) { self.scene.backToStartScreen() }
        leftArea.addChild(backButton)
    }
}
