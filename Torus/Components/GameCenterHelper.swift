//
//  GameCenterHelper.swift
//  Torus Neon
//
//  Created by Moses Harding on 1/4/22.
//

import Foundation
import GameKit

class GameCenterHelper: NSObject {
    typealias CompletionBlock = (Error?) -> Void
    
    var currentMatch: GKTurnBasedMatch?
    
    var canTakeTurnForCurrentMatch: Bool {
        guard let match = currentMatch else {
            return true
        }
        return match.currentParticipant?.player == GKLocalPlayer.local
    }
    
    enum GameCenterHelperError: Error {
        case matchNotFound
    }
    
    static let helper = GameCenterHelper()
    
    var currentMatchmakerVC: GKTurnBasedMatchmakerViewController?
    var viewController: GameViewController?
    var scene: GameScene?
    var startScene: StartingScene?
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var player: GKTurnBasedParticipant?
    var opponent: GKTurnBasedParticipant?
    
    var notificationTitle = "Torus Neon"
    var notificationMessage = "It's your turn"
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            } else {
                print("Error authenticating to Game Center:" + "\(error?.localizedDescription ?? "none")" )
            }
        }
    }
    
    //MATCH
    func presentMatchmaker() {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        let request = GKMatchRequest()
        
        request.minPlayers = 2
        request.maxPlayers = 2
        request.inviteMessage = "Let's Play Torus Neon"
        
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = self
        currentMatchmakerVC = vc
        currentMatchmakerVC?.matchmakingMode = GKMatchmakingMode.inviteOnly
        viewController?.present(vc, animated: true)
    }
    
    func endTurn(_ model: GameModel, completion: @escaping CompletionBlock) {
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        guard let opponent = opponent else {
            fatalError("No opponent found")
        }
        
        do {
            match.message = model.messageToDisplay
            
            print()
            print(model)
            
            match.endTurn(
                withNextParticipants: [opponent],
                turnTimeout: GKTurnTimeoutDefault,
                match: try JSONEncoder().encode(model),
                completionHandler: completion
            )
        } catch {
            completion(error)
        }
    }
    
    func saveCurrentMatch(_ model: GameModel, completion: @escaping CompletionBlock) {
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        do {
            match.saveCurrentTurn(withMatch: try JSONEncoder().encode(model), completionHandler: completion)
        } catch {
            completion(error)
        }
    }
    
    func win(completion: @escaping CompletionBlock) {
        
        print("Win")
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }

        match.participants.forEach {
            if $0.player?.displayName == GKLocalPlayer.local.displayName {
                $0.matchOutcome = .won
            } else {
                $0.matchOutcome = .lost
            }
        }
        
        match.message = "Game over! You lost."
        
        guard let data = match.matchData else { fatalError("GameCenterHelper - Win - No data found for match") }
        match.endMatchInTurn(withMatch: data, completionHandler: completion)

        scene?.gameOver(.won)
    }
    
    func opponentQuit(completion: @escaping CompletionBlock) {
        
        print("Opponent quit")
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }

        match.participants.forEach {
            if $0.player?.displayName == GKLocalPlayer.local.displayName {
                $0.matchOutcome = .won
            } else {
                $0.matchOutcome = .quit
            }
        }
        
        match.message = "Game over! You lost."
        
        guard let data = match.matchData else { fatalError("GameCenterHelper - Win - No data found for match") }
        
        print("Match status \(match.status)")
        
        //if match.status != .ended {
            match.endMatchInTurn(withMatch: data, completionHandler: completion)
        //}

        scene?.gameOver(.opponentQuit)
    }

    func quit(completion: @escaping CompletionBlock) {
        
        print("Quit")
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        var others = [GKTurnBasedParticipant]()
        
        match.participants.forEach {
            if $0.player?.displayName == GKLocalPlayer.local.displayName {
                $0.matchOutcome = .quit
            } else {
                others.append($0)
                $0.matchOutcome = .won
            }
        }
        
        match.message = "Game over! Your opponent quit."
        
        guard let data = match.matchData else { fatalError("GameCenterHelper - Quit - No data found for match") }
        
        match.participantQuitInTurn(with: GKTurnBasedMatch.Outcome.quit, nextParticipants: others, turnTimeout: 0, match: data, completionHandler: completion)

        scene?.gameOver(.lost)
    }
    
    func defeat(completion: @escaping CompletionBlock) {
        
        print("Defeat")
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }

        match.participants.forEach {
            if $0.player?.displayName == GKLocalPlayer.local.displayName {
                $0.matchOutcome = .lost
            } else {
                $0.matchOutcome = .won
            }
        }

        match.message = "Game over! Your won!"
        
        guard let data = match.matchData else { fatalError("GameCenterHelper - Quit - No data found for match") }
        
        match.endMatchInTurn(withMatch: data, completionHandler: completion)

        scene?.gameOver(.lost)
    }
    
    func rematch(completion: @escaping CompletionBlock) {
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        match.rematch() { match, error in
            if let error = error {
                print(error)
                self.scene?.backToStartScreen()
            }
            
            if let match = match {
                self.scene?.backToStartScreen()
                self.currentMatch = match
                NotificationCenter.default.post(name: .presentGame, object: match)
            }
        }
    }
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc failed with error: \(error.localizedDescription).")
    }
}

extension GameCenterHelper: GKLocalPlayerListener {
    
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        
        print("Wants to quit match")
        
        let activeOthers = match.participants.filter { other in
            return other.status == .active && other != player
        }
        
        match.currentParticipant?.matchOutcome = .quit
        activeOthers.forEach { $0.matchOutcome = .won }
        match.message = "Game over! Your opponent quit."
        
        match.endMatchInTurn( withMatch: match.matchData ?? Data() )
        
        match.remove { e in
            if let error = e {
                print("Error deleting match - \(error)")
            }
        }
    }
    
    func player(_ player: GKPlayer, matchEnded: GKTurnBasedMatch) {
        
        print("Match ended")
        
        guard let scene = scene, let currentPlayer = matchEnded.participants.filter({ other in
            return other.player?.displayName == GKLocalPlayer.local.displayName
        }).first else { return }
        
        matchEnded.loadMatchData { data, error in
            
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
        
            scene.gameManager.beginTurn(matchAlreadyOpen: true)
        }
        
        if currentPlayer.matchOutcome == .won {
            print("You won")
            matchEnded.message = "You won!"
            //scene.gameOver(.won)
        } else {
            print("You lost")
            matchEnded.message = "You lost."
            //scene.gameOver(.lost)
        }
    }

    
    //Turn was taken and other player is notified
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
        print("Received match event")
        
        guard match.status != .ended else { return }
        //If matchmaker vc is active (i.e. if user just created a game) then dismiss the vc
        if let vc = currentMatchmakerVC {
            currentMatchmakerVC = nil
            vc.dismiss(animated: true)
        }
        
        if didBecomeActive {
            
            if viewController?.currentScene == .main {
                viewController?.switchScene()
            }
            
            //The user tapped on notification banner and was not in the app
            self.currentMatch = match
            NotificationCenter.default.post(name: .presentGame, object: match)
            
        } else if currentMatch?.matchID == match.matchID {
            
            guard let scene = scene else { fatalError("Scene not passed to GameCenterHelper") }
            //The match that the user is currently playing is already on the screen
            //GKNotificationBanner.show(withTitle: notificationTitle, message: notificationMessage, completionHandler: {})
            
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
                
                scene.model = model
                self.currentMatch = match
                
                print(match, model)
                
                guard let opponent = match.participants.filter({ other in
                    return other.player?.displayName != GKLocalPlayer.local.displayName
                }).first else {
                    print("No opponent found when loading match data")
                    return
                }
                
                print("Match outcome - \(opponent.matchOutcome.rawValue)")
                
                if opponent.matchOutcome == .won {
                    self.defeat { if let error = $0 { print(error) } }
                } else if opponent.matchOutcome == .lost {
                    self.win { if let error = $0 { print(error) } }
                } else if opponent.matchOutcome == .quit {
                    self.opponentQuit { if let error = $0 { print(error) } }
                } else {
                    //Move To view
                    scene.gameManager.beginTurn(matchAlreadyOpen: true)
                }
            }
        } else {
            self.currentMatch = match
            GKNotificationBanner.show(withTitle: notificationTitle, message: match.message, completionHandler: {})
        }
    }
}

extension Notification.Name {
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
    static let canTakeTurn = Notification.Name(rawValue: "canTakeTurn")
    static let presentGame = Notification.Name(rawValue: "presentGame")
}
