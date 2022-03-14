//
//  AuthenticationScene.swift
//  Torus
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
    
    var startButton: ImageNode!
    var logo: ImageNode!
    
    var firstLoad = true
    
    override func didMove(to view: SKView) {

        //set up occurs in setUp after GameViewController calls viewDidLoad
        self.backgroundColor = .black
        GameCenterHelper.helper.currentMatch = nil
        viewController!.gameScene = nil
        
        if firstLoad {
            
            let frame = view.safeAreaLayoutGuide.layoutFrame

            //Set Up Start Button
            startButton = ImageNode("Start Button.png") { self.startOrAuthenticate() }
            var buttonWidth = frame.width * 0.65
            var buttonHeight = startButton.image.size.height * (buttonWidth / startButton.image.size.width)
            startButton.image.size = CGSize(width: buttonWidth, height: buttonHeight)
            startButton.position = midPoint
            self.addChild(startButton)
            
            logo = ImageNode("Torus Neon Logo.png") { print("Logo") }
            buttonWidth = frame.width * 0.9
            buttonHeight = logo.image.size.height * (buttonWidth / logo.image.size.width)
            logo.image.size = CGSize(width: buttonWidth, height: buttonHeight)
            logo.position = CGPoint(x: frame.midX, y: (frame.height * 0.95) - logo.image.size.height / 2)
            self.addChild(logo)
            
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
        if GameCenterHelper.isAuthenticated {
            GameCenterHelper.helper.presentMatchmaker()
        } else {
            let message = UserMessage("You need to be connected to GameCenter to play this game. Please go to your settings and sign in.", fontName: "Menlo-Regular", fontSize: 18, size: CGSize(width: frame.width * 0.8, height: 50), parent: self, position: midPoint)
            message.position = message.position.move(.down, by: message.background.frame.height * 1.5)
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


