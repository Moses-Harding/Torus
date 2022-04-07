//
//  GameManager.swift
//  Torus Neon
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
    
    var lastTorus: Torus?
    var lastTile: Tile?
    
    var gameBoard: GameBoard {
        return scene.playScreen.board
    }
    
    var powerList: PowerList {
        return scene.playScreen.tray.powerList
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
            updateTurnLogic()
            updateUI()
            
            scene.model.firstMove = false
            scene.model.savePreTurnData(from: scene)
            scene.gameStart()
            
            GameCenterHelper.helper.saveCurrentMatch(scene.model) { error in
                if let e = error {
                    print("Error saving turn: \(e)")
                    return
                }
            }
        } else {
            scene.model.loadData(to: scene, matchAlreadyOpen: matchAlreadyOpen)
            //updateTurnLogic()
            scene.toggleWaitingScreen()
            updateUI()
        }
    }
    
    func takeTurn() {
        
        updateTurnLogic()
        updateUI()
        switchTeams()
        scene.model.saveData(from: scene)
        scene.processGameUpdate()
    }
    
    func updateUI() {
        
        print("Update UI called")
        
        gameBoard.unhighlightTiles()
        updateLabels()
        tray.powerList.clear()
        
        checkForWin()
    }
    
    func checkForWin() {
        
        if getOtherTeam(from: currentTeam).teamCount == 0 {
            GameCenterHelper.helper.win { if let error = $0 { print(error) } }
        } else if currentTeam.teamCount == 0 {
            GameCenterHelper.helper.defeat { if let error = $0 { print(error) } }
        }
    }
    
    func updateTurnLogic() {
        
        generateOrbs()
        turnNumber += 1
        deselectCurrent()
        
        scene.toggleWaitingScreen()
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
    
    func generateOrbs(with respawnCount: Int? = nil) {
        
        guard turnNumber % 10 == 0 || respawnCount != nil else { return }
        
        var numberOfOrbs = respawnCount ?? Int(gameBoard.unoccupiedTiles / 5)
        
        var randomIndices = Set(0 ..< gameBoard.tiles.count).shuffled()
        
        while numberOfOrbs > 0 && randomIndices.count > 0 {
            guard let randomIndex = randomIndices.popLast() else { fatalError("No index when trying to generate orb") }
            if let tile = gameBoard.getTileForOrb(from: randomIndex) {
                //print("Generating orb on \(tile), has orb already - \(tile.hasOrb), occupied by \(tile.occupiedBy)")
                tile.populateOrb()
                numberOfOrbs -= 1
            }
        }
    }
    
    func winnerFound() -> TeamNumber? {
        currentTeam.teamCount == 0 ? getOtherTeam(from: currentTeam).teamNumber : nil
    }
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
    
    func deselectCurrent() {
        currentTeam.currentlySelected?.deselect()
        currentTeam.currentlySelected = nil
        powerList.clear()
        gameBoard.unhighlightTiles()
    }
    
    func select(_ torus: Torus, triggeredBy: String) {
        //Selecting a torus (if valid) deselects other torii, then shows valid tiles
        lastTorus = torus
        scene.playScreen.tray.resetTouches()
        
        if TestingManager.helper.verboseTouch { print("Selecting torus triggered by \(triggeredBy)") }
        
        guard !ChangeDecoder.helper.currentlyDecoding else {
            self.powerList.displayPowerConsole(message: .opponentTurn, calledBy: "GameManager - Select Torus - Currently Decoding")
            print("Game Manager - Select Torus - Cannot select because change decoder is decoding")
            return
        }
        
        guard GameCenterHelper.helper.canTakeTurnForCurrentMatch else {
            self.powerList.displayPowerConsole(message: .opponentTurn, calledBy: "GameManager - Select Torus - Opponent's Turn")
            return
        }
        
        //Make sure team is correct
        guard torus.team == currentTeam else {
            var message: PowerConsoleAssets = currentTeam.teamNumber == .one ? .onlyPink : .onlyBlue
            self.powerList.displayPowerConsole(message: message, calledBy: "GameManager - Select Torus - Incorrect Team")
            print("Game Manager - Select Torus - Cannot select because not current team")
            return
        }
        
        guard !scene.isSendingTurn else {
            print("Game Manager - Select Torus - Cannot select because currently sending turn")
            return
        }
        
        guard !powerList.powerIsActivating else {
            print("Game Manager - Select Torus - Cannot select because power is activating")
            return
        }
        

        
        guard scene.model.winner == nil else {
            print("winner found")
            return
        }
        
        gameBoard.unhighlightTiles()
        
        //Deselect torus if same torus
        guard currentTeam.currentlySelected?.name != torus.name else {
            self.deselectCurrent()
            return
        }
        
        currentTeam.currentlySelected?.deselect()
        currentTeam.currentlySelected = torus
        currentTeam.currentlySelected?.select()
        
        gameBoard.highlightValidTiles(surrounding: currentTeam.currentlySelected!)
        
        // scene.scrollView.updateView(with: currentTeam.currentlySelected!.powers, from: torus.team.teamNumber)
        tray.powerList.updateView(with: currentTeam.currentlySelected!.powers, from: torus, calledBy: "Selecting Torus")
    }
    
    func select(_ tile: Tile) {
        //Selecting a tile (if valid) triggers movement / turn taking
        lastTile = tile
        scene.playScreen.tray.resetTouches()
        
        if let torus = currentTeam.currentlySelected, torus.team == currentTeam, tile.validForMovement == true, powerList.powerIsActivating == false  {
            
            MovementManager.helper.move(torus, to: tile) { self.takeTurn() }
            
        }
    }
}

extension GameManager {
    
    func activate(power: PowerType) -> (CGFloat, Bool, (() -> ()))? {
        
        scene.playScreen.tray.resetTouches()
        
        guard let current = currentTeam.currentlySelected else { return nil }
        
        let (waitDuration, isEffective, finalClosure) = PowerManager.helper.activate(power, with: current)
        
        if isEffective {
            let powerLabel = TextNode(power.name, size: current.sprite.size)
            powerLabel.label.fontSize = 20
            powerLabel.position = CGPoint(x: -current.sprite.size.width / 2, y: current.sprite.size.height / 2)
            current.sprite.addChild(powerLabel)
            powerLabel.run(SKAction.wait(forDuration: 0.5)) {
                powerLabel.removeFromParent()
            }
        }
        
        return (waitDuration, isEffective, finalClosure)
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
