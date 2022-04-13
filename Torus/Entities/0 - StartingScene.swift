//
//  AuthenticationScene.swift
//  Torus Neon
//
//  Created by Moses Harding on 2/22/22.
//

import Foundation
import SpriteKit
import GameKit

class StartingScene: SKScene {
    
    var viewController: GameViewController?
    
    var midPoint: CGPoint {
        let point = CGPoint(x: self.frame.midX, y: self.frame.midY)
        return point
    }
    
    var warning: SKSpriteNode!
    
    var notAuthenticated: UserMessage?
    
    var startButton: ImageNode!
    var logo: ImageNode!
    var background: ImageNode!
    
    var firstLoad = true
    
    var selfPlayUnlocked: TextNode?
    var registeredTaps = [TestTapType]() {
        didSet {
            if registeredTaps == [.logo, .background, .logo, .background, .logo, .background] {
                TestingManager.helper.startWithoutGameCenter = true
                selfPlayUnlocked = TextNode("Self-play mode unlocked", size: CGSize(width: frame.width * 0.7, height: frame.height * 0.2))
                selfPlayUnlocked?.position = CGPoint(x: frame.midX - ((selfPlayUnlocked?.label.frame.width)! / 2), y: 50)
                selfPlayUnlocked?.zPosition = 100
                selfPlayUnlocked?.label.fontName = "Courier"
                selfPlayUnlocked?.label.preferredMaxLayoutWidth = frame.width * 0.7
                selfPlayUnlocked?.label.numberOfLines = -1
                addChild(selfPlayUnlocked!)
            } else {
                TestingManager.helper.startWithoutGameCenter = false
                if let label = selfPlayUnlocked {
                    label.removeFromParent()
                    selfPlayUnlocked = nil
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        //set up occurs in setUp after GameViewController calls viewDidLoad
        self.backgroundColor = .black
        GameCenterHelper.helper.currentMatch = nil
        viewController!.gameScene = nil
        
        if let timer = AnimationManager.helper.timer {
            timer.invalidate()
        }

        registeredTaps = []
        
        if firstLoad {
            
            GameCenterHelper.helper.startScene = self
            
            let frame = view.safeAreaLayoutGuide.layoutFrame
            
            logo = ImageNode(LabelAssets.logo.rawValue) { self.registeredTaps.append(.logo) }
            logo.image.size.scale(proportionateTo: .width, with: frame.width * 0.9)
            logo.position = CGPoint(x: frame.midX, y: (frame.height * 0.95) - logo.image.size.height)
            logo.zPosition = 2
            self.addChild(logo)
            
            startButton = ImageNode(ButtonAssets.start.rawValue) { self.startOrAuthenticate() }
            startButton.image.size.scale(proportionateTo: .width, with: frame.width * 0.65)
            startButton.position = logo.position.move(.down, by: logo.image.size.height)
            startButton.zPosition = 2
            self.addChild(startButton)
            
            
            let resize = SKAction.scale(by: 1.025, duration: 1)
            
            startButton.run(SKAction.repeatForever(SKAction.sequence([resize, resize.reversed()])))
            
            background = ImageNode(LabelAssets.background.rawValue) { self.registeredTaps.append(.background) }
            background.image.size.scale(proportionateTo: .width, with: frame.width)
            background.position = CGPoint(x: frame.midX, y: frame.midY)
            background.zPosition = 1
            self.addChild(background)
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(authenticationChanged(_:)),
                name: .authenticationChanged,
                object: nil
            )
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(presentGame(_:)),
                name: .presentGame,
                object: nil
            )
            
            self.firstLoad = false
        }
    }
    
    func startOrAuthenticate() {
        
        if TestingManager.helper.startWithoutGameCenter {
            guard let viewController = self.viewController else { fatalError() }
            let scene = GameScene(model: GameModel(), size: self.size, viewController: viewController)
            viewController.gameScene = scene
            
            //Move To view
            if viewController.currentScene == .starting {
                viewController.switchScene()
            }
        } else {
            if GameCenterHelper.isAuthenticated {
                if let message = notAuthenticated {
                    message.removeFromParent()
                    notAuthenticated = nil
                }
                GameCenterHelper.helper.presentMatchmaker()
            } else {
                notAuthenticated = UserMessage("You need to be connected to GameCenter to play this game. Please go to your settings and sign in.", fontName: "Menlo-Regular", fontSize: 18, size: CGSize(width: frame.width * 0.8, height: 50), parent: self, position: midPoint)
                notAuthenticated!.position = notAuthenticated!.position.move(.down, by: notAuthenticated!.background.frame.height * 2)
            }
        }
    }
    
    @objc private func authenticationChanged(_ notification: Notification) {
        //warning.isHidden = notification.object as? Bool ?? false
    }
    
    @objc private func presentGame(_ notification: Notification) {
        
        guard let match = notification.object as? GKTurnBasedMatch else {
            return
        }
        
        loadAndDisplay(match: match)
    }
    
    // MARK: - Helpers
    
    private func loadAndDisplay(match: GKTurnBasedMatch) {
        
        match.loadMatchData { data, error in
            
            //Load or create a model if one does not exist
            var model: GameModel
            
            if let data = data {
                do {
                    model = try JSONDecoder().decode(GameModel.self, from: data)
                } catch {
                    model = GameModel()
                }
            } else {
                model = GameModel()
            }
            
            //Assign Match to game center
            GameCenterHelper.helper.currentMatch = match
            
            //Assign each participant To Game Center Helper
            match.participants.forEach { participant in
                if participant.player == GKLocalPlayer.local {
                    GameCenterHelper.helper.player = participant
                } else {
                    GameCenterHelper.helper.opponent = participant
                }
            }
            
            //Assign players to model
            if model.player1 == nil {
                model.player1 = GKLocalPlayer.local.displayName
            } else if model.player2 == nil {
                model.player2 = GKLocalPlayer.local.displayName
            }
            
            //Create and load scene
            guard let viewController = self.viewController else { fatalError() }
            let scene = GameScene(model: model, size: self.size, viewController: viewController)
            viewController.gameScene = scene
            
            //Move To view
            if viewController.currentScene == .starting {
                viewController.switchScene()
            }
        }
    }
}


