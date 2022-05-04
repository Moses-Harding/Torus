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
    
    var matchEnded: Bool = false
    
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
    
    func beginTurn(matchAlreadyOpen: Bool, matchEnded: Bool) {
        
        self.matchEnded = matchEnded
        
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
            
            if TestingManager.helper.testShuffling {
                for torus in team1.torii {
                    if torus.torusNumber % 9 == 0 {
                        torus.powerUp(with: .missileStrike)
                        torus.powerUp(with: .shuffle, .column)
                        //PowerManager.helper.activate(PowerType(.shuffle, .column), with: torus)
                    } 
                }
            }
        } else {
            scene.model.loadData(to: scene, matchAlreadyOpen: matchAlreadyOpen)
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
        
        gameBoard.unhighlightTiles()
        updateLabels()
        tray.powerList.clear()
        
        if !self.matchEnded {
            checkForWin()
        }
    }
    
    func checkForWin() {
        
        print("Check for win")
        
        if getOtherTeam(from: currentTeam).teamCount == 0 {
            scene.model.winner = currentTeam.teamNumber == .one ? scene.model.player1 : scene.model.player2
            scene.model.saveData(from: scene)
            GameCenterHelper.helper.win(model: scene.model, endTurn: true) { if let error = $0 { print(error) } }
        } else if currentTeam.teamCount == 0 {
            scene.model.winner = getOtherTeam(from: currentTeam).teamNumber  == .one ? scene.model.player1 : scene.model.player2
            scene.model.saveData(from: scene)
            GameCenterHelper.helper.defeat(model: scene.model, endTurn: true) { if let error = $0 { print(error) } }
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
                tile.populateOrb(calledBy: "Generate Orbs")
                numberOfOrbs -= 1
            }
        }
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
        
        //Make sure decoding is done
        guard !ChangeDecoder.helper.currentlyDecoding else {
            self.powerList.displayPowerConsole(message: .processing, calledBy: "GameManager - Select Torus - Currently Decoding")
            print("Game Manager - Select Torus - Cannot select because change decoder is decoding")
            return
        }
        
        //Make sure team is correct
        guard (GameCenterHelper.helper.canTakeTurnForCurrentMatch && torus.team == currentTeam) || (!GameCenterHelper.helper.canTakeTurnForCurrentMatch && torus.team != currentTeam) else {
            if GameCenterHelper.helper.canTakeTurnForCurrentMatch {
                let message: PowerConsoleAssets = currentTeam.teamNumber == .one ? .onlyPink : .onlyBlue
                self.powerList.displayPowerConsole(message: message, calledBy: "GameManager - Select Torus - Incorrect Team")
            }
            print("Game Manager - Select Torus - Cannot select because not current team")
            return
        }
        
        //Make sure turn isn't sending
        guard !scene.isSendingTurn else {
            print("Game Manager - Select Torus - Cannot select because currently sending turn")
            return
        }
        
        //Make sure console state is normal
        guard powerList.consoleIsDisplaying == .normal else {
            print("Game Manager - Select Torus - Cannot select because power is not in correct mode")
            return
        }
        
        guard scene.model.winner == nil else {
            print("Winner found")
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
        tray.powerList.updateView(with: currentTeam.currentlySelected!.powers, from: torus, calledBy: "Selecting Torus")
    }
    
    func select(_ tile: Tile) {
        //Selecting a tile (if valid) triggers movement / turn taking
        lastTile = tile
        scene.playScreen.tray.resetTouches()
        
        guard GameCenterHelper.helper.canTakeTurnForCurrentMatch else {
            return
        }
        
        if let torus = currentTeam.currentlySelected, torus.team == currentTeam, tile.validForMovement == true, powerList.powerIsActivating == false  {
            
            _ = MovementManager.helper.move(torus, to: tile) { self.takeTurn() }
            
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
