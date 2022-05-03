//
//  2 - Tray.swift
//  Torus Neon
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

    var backButton: ImageNode!
    var endTurnButton: ImageNode!
    var forfeitButton: ImageNode!
    
    var leftArea: OverlaySprite!
    var middleArea: OverlaySprite!
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
        let size = sprite.size.scaled(x: 0.3, y: 0.9)
        let errorBlock: ((Error?) -> Void) = { if let error = $0 { print(error) } }
        
        leftArea = OverlaySprite(primaryTexture: blank, color: UIColor.clear, blend: true, size: size, parentSprite: sprite)
        middleArea = OverlaySprite(primaryTexture: blank, color: UIColor.clear, blend: true, size: size, parentSprite: sprite)
        rightArea = OverlaySprite(primaryTexture: blank, color: UIColor.clear, blend: true, size: size, parentSprite: sprite)
        

        leftArea.position = CGPoint(x: -size.width * 1.2, y: 0)
        middleArea.position = CGPoint(x: 0, y: 0)
        rightArea.position = CGPoint(x: size.width * 1.2, y: 0)
        
        backButton = ImageNode(ButtonAssets.back.rawValue) { self.scene.backToStartScreen() }
        endTurnButton = ImageNode(ButtonAssets.endTurn.rawValue) { self.manager.takeTurn() }
        forfeitButton = ImageNode(ButtonAssets.forfeit.rawValue) { self.scene.forfeit() }
        
        backButton.image.size.scale(proportionateTo: .height, of: size)
        endTurnButton.image.size.scale(proportionateTo: .height, of: size)
        forfeitButton.image.size.scale(proportionateTo: .height, of: size)
        
        backButton.zPosition = leftArea.zPosition + 10
        endTurnButton.zPosition = middleArea.zPosition + 10
        forfeitButton.zPosition = rightArea.zPosition + 10
        
        leftArea.addChild(backButton)
        middleArea.addChild(endTurnButton)
        rightArea.addChild(forfeitButton)
    }
}
