//
//  PlayScreen.swift
//  Triple Bomb
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
}
