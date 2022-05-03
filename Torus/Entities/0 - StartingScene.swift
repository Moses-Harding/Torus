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
    var tutorialButton: ImageNode!
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
    
    // MARK: Tutorial
    var tutorialStep = 0
    var tutorialBackground: SKSpriteNode?
    
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
            
            logo = ImageNode(LabelAssets.logo.rawValue) {
                self.registeredTaps.append(.logo)
                self.showNextTutorialStep()
            }
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
            
            
            tutorialButton = ImageNode(ButtonAssets.tutorial.rawValue) { self.showNextTutorialStep() }
            tutorialButton.image.size.scale(proportionateTo: .width, with: frame.width * 0.65)
            tutorialButton.position = startButton.position.move(.down, by: startButton.image.size.height)
            tutorialButton.zPosition = 2
            self.addChild(tutorialButton)
            
            tutorialButton.run(SKAction.repeatForever(SKAction.sequence([resize, resize.reversed()])))
            
            
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
    
    // MARK: Tutorial
    
    func showNextTutorialStep() {
        
        guard let view = self.view else { return }
        
        if let tutorialBackground = tutorialBackground {
            tutorialBackground.removeAllChildren()
        }
        
        var imageName: String
        var messageText: String
        
        if tutorialStep == 0 {
            
            // 1 - Add Background
            tutorialBackground = SKSpriteNode(imageNamed: TutorialAssets.background.rawValue)
            tutorialBackground?.size = background.image.size
            tutorialBackground?.position = self.background.position
            tutorialBackground?.zPosition = 100
            self.addChild(tutorialBackground!)
            
            imageName = TutorialAssets.t1.rawValue
            messageText = "1.    Tap on a piece to move. The tiles that the piece can move to are highlighted in green. Each piece can jump onto another piece to kill it or jump onto an orb to gain a power."
        } else if tutorialStep == 1 {
            imageName = TutorialAssets.t2.rawValue
            messageText = "2.    Sometimes the elevation of tiles change, so pieces can’t move onto them. In this example, the piece can’t move to the right. You can change this by using powers that change the elevation of tiles."
        } else if tutorialStep == 2 {
            imageName = TutorialAssets.t3.rawValue
            messageText = "3.    When you step on an orb, your piece gains a new power. Powers can do many different things – to find out what a certain power does, press and hold on it. Powers will usually affect an entire row, column, or radius (the tiles immediately surrounding the piece in question)."
        } else if tutorialStep == 3 {
            imageName = TutorialAssets.t4.rawValue
            messageText = "4.    When you step on an orb, your piece gains a new power. Powers can do many different things – to find out what a certain power does, press and hold on it. Powers will usually affect an entire row, column, or radius (the tiles immediately surrounding the piece in question)."
        } else {
            tutorialStep = 0
            tutorialBackground?.removeAllChildren()
            tutorialBackground?.removeFromParent()
            tutorialBackground = nil
            return
        }
        
        
        // 2 - Add Tutorial Iamge
        let image = ImageNode(imageName) { self.showNextTutorialStep() }
        image.image.size.scale(proportionateTo: .width, with: tutorialBackground!.frame.width * 0.8)
        image.zPosition = 101
        image.image.position = CGPoint.zero.move(.up, by: image.image.size.height / 4)//midPoint.move(.up, by: image.image.size.height / 2)
        tutorialBackground!.addChild(image)
        

        //let tutorialText = TextNode(tutorial1, size: CGSize(width: view.frame.width, height: view.frame.height / 2))
        let position = CGPoint(x: 0, y: -image.image.frame.height / 2)
        
        let message = UserMessage(messageText, fontSize: 16, size: CGSize(width: view.frame.width * 0.9, height: view.frame.height / 2), parent: tutorialBackground!, position: position) { self.showNextTutorialStep() }
        message.zPosition = 101
        
        let continueButton = ImageNode(ButtonAssets.continueButton.rawValue) { self.showNextTutorialStep() }
        continueButton.image.size.scale(proportionateTo: .width, with: frame.width * 0.35)
        continueButton.image.position = message.position.move(.down, by: message.label.frame.height)
        continueButton.zPosition = 101
        tutorialBackground!.addChild(continueButton)
        
        tutorialStep += 1
    }
}
