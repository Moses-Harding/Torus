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
    
    var buttonSize: CGSize { self.view?.frame.size.scaled(x: 0.5, y: 0.2) ?? CGSize.zero }
    
    var startButton: TouchNode!
    
    var firstLoad = true
    
    override func didMove(to view: SKView) {

        //set up occurs in setUp after GameViewController calls viewDidLoad
        self.backgroundColor = .black
        GameCenterHelper.helper.currentMatch = nil
        viewController!.gameScene = nil
        
        if firstLoad {
            

            
            //Set Up Start Button
            startButton = TouchNode("Start Game", size: buttonSize) { self.startOrAuthenticate() }
            startButton.position = midPoint.move(.left, by: buttonSize.width / 2)
            self.addChild(startButton)
            
            warning = SKSpriteNode(imageNamed: "GameCenterWarning")
            let newHeightRatio = view.frame.size.width * 0.95 / warning.size.width
            warning.size = CGSize(width: view.frame.size.width * 0.95, height: warning.size.height * newHeightRatio)
            warning.position = CGPoint(x: view.frame.midX, y: warning.size.height / 1.5)
            self.addChild(warning)
            
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
        }
    }
    
    @objc private func authenticationChanged(_ notification: Notification) {
        warning.isHidden = notification.object as? Bool ?? false
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


