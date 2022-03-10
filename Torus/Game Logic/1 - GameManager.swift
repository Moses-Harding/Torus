//
//  GameManager.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit
import GameKit

class GameManager {
    
    unowned var scene: GameScene
    
    var team1: Team!
    var team2: Team!
    var currentTeam: Team!
    var userTeam: Team!

    var turnNumber = 0
    
    var gameBoard: GameBoard {
        return scene.playScreen.board
    }
    
    var tray: Tray {
        return scene.playScreen.tray
    }
    
    //Init
    
    init(scene: GameScene) {
        
        self.scene = scene
        
        print("6. GameManager -> Setting Up Tiles")
        createTiles()
        print("7. GameManager -> Setting Up Teams")
        createTeams()
    }
}

extension GameManager { //Taking Turn
    
    func beginTurn(matchAlreadyOpen: Bool) {

        print("\n______\nBegin turn")
        
        if scene.model.firstMove && GameCenterHelper.helper.canTakeTurnForCurrentMatch {
            print("8. GameManager -> Setting Up Torii")
            createTorii()
            updateGameLogic()
            updateGameBoard()
            gameBoard.syncUnoccupiedTiles()
            
            scene.model.firstMove = false
            scene.model.savePreTurnData(from: scene)
            //scene.model.saveData(from: scene)
            
            GameCenterHelper.helper.saveCurrentMatch(scene.model) { error in
                if let e = error {
                    print("Error saving turn: \(e)")
                    return
                }
            }
        } else {
            scene.model.loadData(to: scene, matchAlreadyOpen: matchAlreadyOpen)
            updateGameLogic()
            updateGameBoard()
        }
    }
    
    func takeTurn() {
        
        updateGameLogic()
        updateGameBoard()
        switchTeams()
        scene.model.saveData(from: scene)
        scene.processGameUpdate()
    }
    
    func updateGameBoard() {
        
        gameBoard.unhighlightTiles()
        updateLabels()
        scene.scrollView?.clear()
    }
    
    func updateGameLogic() {
        
        generateOrbs()
        turnNumber += 1
        
        currentTeam.currentlySelected?.deselect()
        currentTeam.currentlySelected = nil
    }
    
    func updateLabels() {
        
        tray.redLabel.text = String(team1.teamCount)
        tray.blueLabel.text = String(team2.teamCount)
    }
    
    func switchTeams() {

        currentTeam = currentTeam == team1 ? team2 : team1
        changeTeam(to: currentTeam.teamNumber)
    }
    
    func getOtherTeam(from team: Team) -> Team {
        
        return team == team1 ? team2 : team1
    }
    
    func changeTeam(to number: TeamNumber) {
        
        if number == .one {
            tray.redLabelBackground.setPrimaryTexture()
            tray.blueLabelBackground.setPrimaryTexture()
            currentTeam = team1
        } else {
            tray.redLabelBackground.setSecondaryTexture()
            tray.blueLabelBackground.setSecondaryTexture()
            currentTeam = team2
        }
    }
    
    func generateOrbs() {

        guard turnNumber % 10 == 0 else { return }
        
        var numberOfOrbs = TestingManager.helper.testOrbs ? TestingManager.helper.numberOfOrbsToTest : Int(gameBoard.unoccupiedTiles.count / 5)
        
        var randomIndices = Set(0 ..< gameBoard.unoccupiedTiles.count).shuffled()
        
        while numberOfOrbs > 0 && randomIndices.count > 0 {
            guard let randomIndex = randomIndices.popLast() else { fatalError("No index when trying to generate orb") }
            if let tile = gameBoard.getTileForOrb(from: randomIndex) { tile.populateOrb() }
            numberOfOrbs -= 1
        }
    }
    
    func winnerFound() -> TeamNumber? {
        currentTeam.teamCount == 0 ? getOtherTeam(from: currentTeam).teamNumber : nil
    }
}

extension GameManager { //Executing Actions Of Turn
    
}

extension GameManager { //Set Up

    func createTiles() {
        
        gameBoard.setUpTiles()
    }
    
    func createTeams() {
        
        team1 = Team(teamNumber: .one, teamColor: .red, gameManager: self)
        team2 = Team(teamNumber: .two, teamColor: .blue, gameManager: self)
        currentTeam = team1
    }
    
    func createTorii() {
        
        team1.createTeam()
        team2.createTeam()
    }
}

extension GameManager { //User Touch Interaction / Selection
    
    func select(_ torus: Torus) {
        //Selecting a torus (if valid) deselects other torii, then shows valid tiles
        
        //Make sure team is correct
        guard torus.team == currentTeam else {
            print("not current team")
            return
        }
        
        guard !scene.isSendingTurn else {
            print("is sending turn")
            return
        }
        
        guard GameCenterHelper.helper.canTakeTurnForCurrentMatch else {
            print("cannot take turn for current match")
            return
        }
        
        guard scene.model.winner == nil else {
            print("winner found")
            return
        }
        
        gameBoard.unhighlightTiles()
        
        //Deselect torus if same torus
        guard currentTeam.currentlySelected?.name != torus.name else {
            torus.deselect()
            currentTeam.currentlySelected = nil
            return
        }
        
        currentTeam.currentlySelected?.deselect()
        currentTeam.currentlySelected = torus
        currentTeam.currentlySelected?.select()
        
        gameBoard.highlightValidTiles(surrounding: currentTeam.currentlySelected!)
        
        scene.scrollView.updateView(with: currentTeam.currentlySelected!.powers)
    }
    
    func select(_ tile: Tile) {
        //Selecting a tile (if valid) triggers movement / turn taking
        
        if let torus = currentTeam.currentlySelected, torus.team == currentTeam, tile.validForMovement == true  {
            
            MovementManager.helper.move(torus, to: tile) { self.takeTurn() }

        }
    }
}

extension GameManager {
    
    func activate(power: PowerType) {
        
        guard let current = currentTeam.currentlySelected else { return }
        
        let completion = {
            self.select(current)
            self.updateLabels()
            self.select(current)
        }
        
        PowerManager.helper.activate(power, with: current, completion: completion)
    }
}

extension GameManager { //Retrieve
    
    func getTorus(with name: String) -> Torus? {

        let team1Torus = team1.getTorus(with: name)
        let team2Torus = team2.getTorus(with: name)
        
        if team1Torus != nil {
            return team1Torus
        } else if team2Torus != nil {
            return team2Torus
        } else {
            return nil
        }
    }
}
