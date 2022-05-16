//
//  PlayScreen.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/12/21.
//

import Foundation
import SpriteKit

class PlayScreen: Entity {
    
    //frames
    var frame: CGRect
    var boardFrame: CGRect!
    var trayFrame: CGRect!
    var buttonTrayFrame: CGRect!
    
    //children
    var board: GameBoard!
    var tray: Tray!
    var buttonTray: ButtonTray!
    
    // Error
    var errorBackground: ImageNode!
    var errorMessage: UserMessage!
    
    init(scene: GameScene) {
        
        self.frame = scene.safeFrame
        
        let sprite = PlayScreenSprite(size: frame.size)
        
        super.init(scene: scene, sprite: sprite, position: scene.midPoint, spriteLevel: .playScreen, name: "playScreen", size: frame.size)
        
        setUpFrames()
        print("3. PlayScreen -> Setting Up GameBoard")
        setUpBoard()
        print("4. PlayScreen -> Setting Up Tray And Button Tray")
        setUpButtonTray()
        setUpTray()
    }
    
    func setUpFrames() {
        
        let trayFrameHeight = frame.height * 0.225
        trayFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: trayFrameHeight)
        
        let boardFrameHeight = frame.height * 0.675
        boardFrame = CGRect(x: frame.origin.x, y: trayFrame.origin.y + trayFrameHeight + (frame.height * 0.025), width: frame.width, height: boardFrameHeight)
        
        let buttonFrameHeight = frame.height * 0.05
        buttonTrayFrame = CGRect(x: frame.origin.x, y: boardFrame.origin.y + boardFrameHeight, width: frame.width, height: buttonFrameHeight)
        
        let errorFrameHeight = trayFrameHeight + boardFrameHeight + (frame.height * 0.025)
        let errorFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: errorFrameHeight)
        let errorOrigin = CGPoint(x: errorFrame.midX, y: errorFrame.midY)
        let errorSize = errorFrame.size
        
        errorBackground = ImageNode(TutorialAssets.background.rawValue)
        errorBackground.image.size = errorSize
        errorBackground.image.position = errorOrigin
        errorBackground.zPosition = 100
        errorBackground.alpha = 0.2
        scene.addChild(errorBackground)
        
        errorMessage = UserMessage("It looks like you're not connected to GameCenter. Please hit the 'Back' button and try to reconnect", fontSize: 18, size: CGSize(width: errorFrame.width * 0.9, height: errorFrame.height * 0.3), parent: scene, position: errorOrigin)
        errorMessage.zPosition = 101
        
        
        errorBackground.isHidden = true
        errorMessage.isHidden = true
    }
    
    func setUpButtonTray() {
        self.buttonTray = ButtonTray(scene: scene, playScreen: self)
    }
    
    func setUpBoard() {
        self.board = GameBoard(scene: scene, playScreen: self)
    }
    
    func setUpTray() {
        self.tray = Tray(scene: scene, playScreen: self)
    }
    
    func showDisconnectedMessage() {
        
        guard !TestingManager.helper.startWithoutGameCenter else { return }
        
        errorBackground.isHidden = false
        errorMessage.isHidden = false
    }
    
    func hideDisconnectedMessage() {
        errorBackground.isHidden = true
        errorMessage.isHidden = true
    }
}
