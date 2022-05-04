//
//  GameScene.swift
//  Torus Neon
//
//  Created by Moses Harding on 9/27/21.
//

import SpriteKit
import GameplayKit
import GameKit

class GameScene: SKScene {
    
    var midPoint: CGPoint {
        let point = CGPoint(x: self.frame.midX, y: self.frame.midY)
        return point
    }
    
    var waitingScreen: SKSpriteNode?
    
    var numberOfRows = TestingManager.helper.testRows ?? 9
    var numberOfColumns = TestingManager.helper.testCols ?? 7
    
    var safeFrame: CGRect!
    
    var playScreen: PlayScreen!
    var gameManager: GameManager!
    
    var viewController: GameViewController?
    
    var gameOver = false
    
    var model: GameModel
    var isSendingTurn = false
    
    init(model: GameModel, size: CGSize, viewController: GameViewController) {
        
        self.model = model
        self.viewController = viewController
        
        super.init(size: size)
        
        viewController.gameScene = self
        scaleMode = .resizeFill
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        //set up occurs in setUp after GameViewController calls viewDidLoad
        self.backgroundColor = .black
        
        setUp()
    
        gameManager.beginTurn(matchAlreadyOpen: false, matchEnded: model.winner != nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged(_:)),
            name: .authenticationChanged,
            object: nil
        )
    }
    
    func setUp() { //This is called after GameViewController calls viewDidLoad
        
        print("1. GameViewController -> Setting up GameScene")
        
        let safeArea = self.view!.safeAreaLayoutGuide.layoutFrame
        
        let safeWidth = safeArea.width * 0.95
        let safeHeight = safeArea.height * 0.95
        
        
        self.safeFrame = CGRect(x: safeArea.origin.x + (safeArea.width * 0.025), y: safeArea.origin.y + (safeArea.height * 0.025), width: safeWidth, height: safeHeight)
        
        print("2. GameScene -> Setting Up PlayScreen")
        self.playScreen = PlayScreen(scene: self)
        
        print("5. GameScene -> Setting Up GameManager")
        self.gameManager = GameManager(scene: self)
        
        setUpManagers()
    }
    
    func setUpManagers() {
        
        AnimationManager.helper.scene = self
        MovementManager.helper.scene = self
        PowerManager.helper.scene = self
        ChangeDecoder.helper.gameScene = self
        GameCenterHelper.helper.scene = self
    }
    
    //Game Updates
    
    func processGameUpdate() {
        
        print("\nProcessing update\n____________")
        
        isSendingTurn = true
            GameCenterHelper.helper.endTurn(model) { error in
                defer { self.isSendingTurn = false }
                self.toggleWaitingScreen()
                
                if let e = error {
                    print("Error ending turn: \(e)")

                    self.playScreen.showDisconnectedMessage()
                    return
                }
            print("Turn is ended\n____________")
        }
    }
    
    //Move To Views
    
    func backToStartScreen() {
        
        guard let viewController = viewController else { fatalError("No view controller passed to game view scene") }
        
        if viewController.currentScene == .main { viewController.switchScene() }
    }
    
    @objc func toggleWaitingScreen() {
        
        if gameOver {
            waitingScreen?.isHidden = true
            return
        }

        if waitingScreen == nil {
            waitingScreen = SKSpriteNode(imageNamed: "Waiting For Opponent Label")
            self.addChild(waitingScreen!)
            waitingScreen?.position = midPoint.move(.up, by: frame.height / 4)
            waitingScreen?.size.scale(proportionateTo: .width, of: self.frame.size)
            waitingScreen?.zPosition = SpriteLevel.topLevel.rawValue + 10
            waitingScreen?.run(SKAction.repeatForever(
                SKAction.sequence([SKAction.fadeOut(withDuration: 1.5), SKAction.fadeIn(withDuration: 1.5)])))
        }

        waitingScreen?.isHidden = GameCenterHelper.helper.canTakeTurnForCurrentMatch
        waitingScreen?.isPaused = GameCenterHelper.helper.canTakeTurnForCurrentMatch
        playScreen.tray.powerList.clearGate.isHidden = GameCenterHelper.helper.canTakeTurnForCurrentMatch
        playScreen.buttonTray.endTurnButton.isEnabled = GameCenterHelper.helper.canTakeTurnForCurrentMatch
        playScreen.buttonTray.forfeitButton.isEnabled = GameCenterHelper.helper.canTakeTurnForCurrentMatch
    }
    
    func gameStart() {
        
        let gameStart = SKSpriteNode(imageNamed: LabelAssets.gameStart.rawValue)
        self.addChild(gameStart)
        gameStart.position = midPoint.move(.up, by: frame.height / 4)
        gameStart.size.scale(proportionateTo: .width, of: self.frame.size)
        gameStart.zPosition = SpriteLevel.topLevel.rawValue + 10
        
        gameStart.run(SKAction.sequence([SKAction.wait(forDuration: 0.25), SKAction.fadeOut(withDuration: 2)])) {
            gameStart.removeFromParent()
        }
    }
    
    enum GameResult {
        case won, lost, opponentQuit
    }
    
    func gameOver(_ result: GameResult) {
        
        gameOver = true
        
        var imageName: String
        switch result {
        case .won:
            imageName = LabelAssets.victory.rawValue
        case .lost:
            imageName = LabelAssets.defeat.rawValue
        case .opponentQuit:
            imageName = LabelAssets.opponentQuit.rawValue
        }
        
        let resultLabel = SKSpriteNode(imageNamed: imageName)
        self.addChild(resultLabel)
        resultLabel.position = midPoint.move(.up, by: frame.height / 4)
        resultLabel.size.scale(proportionateTo: .width, of: self.frame.size)
        resultLabel.zPosition = SpriteLevel.topLevel.rawValue + 10
        
        AnimationManager.helper.finalAnimation()
        
        let rematchButton = ImageNode(ButtonAssets.rematch.rawValue) { GameCenterHelper.helper.rematch { if let error = $0 { print(error) } } }
        rematchButton.position = midPoint
        rematchButton.zPosition = SpriteLevel.topLevel.rawValue + 10
        rematchButton.image.size.scale(proportionateTo: .width, with: frame.size.width * 0.65)
        
        if GameCenterHelper.helper.canTakeTurnForCurrentMatch {
         addChild(rematchButton)
        }
        
        let quitButton = ImageNode(ButtonAssets.quit.rawValue) { self.backToStartScreen() }
        quitButton.position = midPoint.move(.down, by: rematchButton.image.size.height)
        quitButton.zPosition = SpriteLevel.topLevel.rawValue + 10
        quitButton.image.size.scale(proportionateTo: .width, with: frame.size.width * 0.65)
        addChild(quitButton)
        
        playScreen.buttonTray.endTurnButton.isEnabled = false
        playScreen.buttonTray.forfeitButton.isEnabled = false
        playScreen.buttonTray.backButton.isEnabled = false
        
        waitingScreen?.isHidden = true
    }
    
    func forfeit() {
        
        let background = ImageNode(TutorialAssets.background.rawValue)
        background.image.size = view!.frame.size
        background.position = midPoint
        background.zPosition = 100
        background.alpha = 0.2
        addChild(background)

        let forfeitText = UserMessage("Are you sure you want to forfeit?", size: CGSize(width: view!.frame.width * 0.8, height: view!.frame.height * 0.3), parent: self, position: midPoint.move(.up, by: frame.height / 4))
        forfeitText.zPosition = 101
        
        let forfeitConfirmation = ImageNode(ButtonAssets.forfeitConfirmation.rawValue)
        forfeitConfirmation.position = midPoint
        forfeitConfirmation.zPosition = 101
        forfeitConfirmation.image.size.scale(proportionateTo: .width, with: frame.size.width * 0.65)
        addChild(forfeitConfirmation)

        let nevermind = ImageNode(ButtonAssets.forfeitNevermind.rawValue)
        nevermind.position = midPoint.move(.down, by: forfeitConfirmation.image.size.height)
        nevermind.zPosition = 101
        nevermind.image.size.scale(proportionateTo: .width, with: frame.size.width * 0.65)
        addChild(nevermind)
        
        let removeAllForfeitAssets = { [self] in
            background.removeFromParent()
            forfeitText.removeFromParent()
            forfeitConfirmation.removeFromParent()
            nevermind.removeFromParent()
            playScreen.buttonTray.endTurnButton.isEnabled = true
            playScreen.buttonTray.forfeitButton.isEnabled = true
            playScreen.buttonTray.backButton.isEnabled = true
        }
        nevermind.actionBlock = removeAllForfeitAssets
        forfeitConfirmation.actionBlock =  { [self] in
            removeAllForfeitAssets()
            model.winner = model.currentTeam == .one ? model.player2 : model.player1
            model.saveData(from: self)
            GameCenterHelper.helper.quit(completion: { if let error = $0 { print(error) } })
        }
        

        
        playScreen.buttonTray.endTurnButton.isEnabled = false
        playScreen.buttonTray.forfeitButton.isEnabled = false
        playScreen.buttonTray.backButton.isEnabled = false
        
        waitingScreen?.isHidden = true
    }
    
    @objc private func authenticationChanged(_ notification: Notification) {
        if notification.object as? Bool ?? false {
            playScreen.hideDisconnectedMessage()
        } else {
            playScreen.showDisconnectedMessage()
        }
    }
}
