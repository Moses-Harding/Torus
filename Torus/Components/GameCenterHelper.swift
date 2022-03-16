//
//  GameCenterHelper.swift
//  Triple Bomb
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
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var player: GKTurnBasedParticipant?
    var opponent: GKTurnBasedParticipant?
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                //Allows user to receive GKInviteEventListener callbacks
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
                turnTimeout: GKExchangeTimeoutDefault,
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
        
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }

        match.currentParticipant?.matchOutcome = .won
        match.participants.forEach { other in
            other.matchOutcome = .lost
        }
        
        match.endMatchInTurn(
            withMatch: match.matchData ?? Data(),
            completionHandler: completion
        )
    }
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
    }
}

extension GameCenterHelper: GKLocalPlayerListener {
    
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        
        print("Wants to quit match")
        
        let activeOthers = match.participants.filter { other in
            return other.status == .active && other != player
        }
        
        match.currentParticipant?.matchOutcome = .lost
        activeOthers.forEach { $0.matchOutcome = .won }
        
        match.endMatchInTurn( withMatch: match.matchData ?? Data() )
 
        match.remove { e in
            if let error = e {
                print("Error deleting match - \(error)")
            } else {
                print("Match removed")
            }
        }
    }
    
    //Turn was taken and other player is notified
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
        print("Received turn event")

        //If matchmaker vc is active (i.e. if user just created a game) then dismiss the vc
        if let vc = currentMatchmakerVC {
            currentMatchmakerVC = nil
            vc.dismiss(animated: true)
        }
        
        if didBecomeActive {
            //The user tapped on notification banner and was not in the app
            self.currentMatch = match
            NotificationCenter.default.post(name: .presentGame, object: match)
            
        } else if currentMatch?.matchID == match.matchID {
            
            guard let scene = scene else { fatalError("Scene not passed to GameCenterHelper") }
            //The match that the user is currently playing is already on the screen
            GKNotificationBanner.show(withTitle: "Time for your turn", message: "Time for your turn", completionHandler: {})
            
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
                
                //Move To view
                scene.gameManager.beginTurn(matchAlreadyOpen: true)
            }
        } else {
            print("Player had game open but not in the right match")
        }
    }
}

extension Notification.Name {
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}
