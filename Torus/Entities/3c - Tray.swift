//
//  2 - Tray.swift
//  Triple Bomb
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
    
    var turnIndicator: OverlaySprite!
    
    var textBoxArea: TrayItemSprite!
    
    var leftArea: OverlaySprite!
    var rightArea: OverlaySprite!
    
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
        
        redLabelBackground = TrayItemSprite(primaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.redHighlighted.rawValue), secondaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.redUnhighlighted.rawValue), color: UIColor.clear, size: labelSize, parentSprite: leftArea)
        blueLabelBackground = TrayItemSprite(primaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.blueUnhighlighted.rawValue), secondaryTexture: SKTexture(imageNamed: BackgroundLabelAsset.blueHighlighted.rawValue), color: UIColor.clear, size: labelSize, parentSprite: leftArea)
        
        redLabelBackground.position = CGPoint(x: 0, y: labelY)
        blueLabelBackground.position = CGPoint(x: 0, y: -labelY)
        
        redLabel = LabelSprite(parentSprite: redLabelBackground)
        blueLabel = LabelSprite(parentSprite: blueLabelBackground)
        
        // Text Area
        let textBoxSize = rightSize.scaled(by: 0.9)
        textBoxArea = TrayItemSprite(primaryTexture: SKTexture(imageNamed: TraySpriteAssets.redTextBox.rawValue), secondaryTexture: SKTexture(imageNamed: TraySpriteAssets.blueTextBox.rawValue), color: UIColor.clear, size: textBoxSize, parentSprite: rightArea)
    }
}
