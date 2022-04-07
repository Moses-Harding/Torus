//
//  GameViewController.swift
//  Torus Neon
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
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    func switchScene() {
        
        guard let view = self.view as? SKView, let gameScene = self.gameScene else { fatalError() }
        
        guard let filter = CIFilter(name: "CIRippleTransition") else { fatalError() }
        
        //filter.setValue(view.frame.width, forKey: "inputWidth")
        //filter.setValue(CIVector(x: view.frame.width, y: view.frame.height), forKey: "inputExtent")
        //filter.setValue(5, forKey: "inputTime")
        //filter.setDefaults()
        //filter.setValue(5.0, forKey: "inputScale")
        
       
        
        let transition = SKTransition(ciFilter: filter, duration: 1)
        
        switch currentScene {
        case .starting:
            view.presentScene(gameScene, transition: transition)
            currentScene = .main
        case .main:
            view.presentScene(startingScene, transition: transition)
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
    
    override func viewDidAppear(_ animated: Bool) {
    }
}
