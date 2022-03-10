//
//  GameViewController.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    enum SceneType {
        case starting, main
    }
    
    var currentScene: SceneType = .starting
    var startingScene: StartingScene!
    var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameCenterHelper.helper.viewController = self
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            
            startingScene = StartingScene(size: view.frame.size)
            startingScene.scaleMode = .aspectFill
            startingScene.viewController = self
            
            view.presentScene(startingScene)

            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func switchScene() {
        
        guard let view = self.view as? SKView, let gameScene = self.gameScene else { fatalError() }
        
        switch currentScene {
        case .starting:
            view.presentScene(gameScene)
            currentScene = .main
        case .main:
            view.presentScene(startingScene)
            currentScene = .starting
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) { //Scene is set up after view appears so that the safe area is accurate
    }
}
