//
//  GameScene.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var midPoint: CGPoint {
        let point = CGPoint(x: self.frame.midX, y: self.frame.midY)
        return point
    }
    
    var waitingScreen: SKSpriteNode?
    
    var numberOfRows = 9
    var numberOfColumns = 7
    
    var safeFrame: CGRect!
    
    var playScreen: PlayScreen!
    var gameManager: GameManager!

    //var scrollView: ScrollView!
    
    var viewController: GameViewController?
    
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
        gameManager.beginTurn(matchAlreadyOpen: false)
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
        setUpScrollView()
    }
    
    func setUpManagers() {
        
        AnimationManager.helper.scene = self
        MovementManager.helper.scene = self
        PowerManager.helper.scene = self
        ChangeDecoder.helper.gameScene = self
        GameCenterHelper.helper.scene = self
    }
    
    func setUpScrollView() {
        
        /*
        let frame = playScreen.tray.textBoxArea.frame
        
        let point = self.convert(frame.origin, from: playScreen.tray.textBoxArea)
        let convertedPoint = self.convertPoint(toView: point)
        let origin = CGPoint(x: convertedPoint.x, y: convertedPoint.y - frame.height + frame.height / 10)
        
        scrollView = ScrollView(scene: self, frame: CGRect(origin: origin, size: frame.size.scaled(x: 0.95, y: 0.8)))
        view?.addSubview(scrollView)
         */
    }
    
    //Game Updates
    
    func processGameUpdate() {
        
        print("\nProcessing update\n____________")
        
        isSendingTurn = true
        
        if model.winner != nil {
            GameCenterHelper.helper.win { error in
                defer { self.isSendingTurn = false }
                
                if let e = error {
                    print("Error winning match: \(e)")
                    return
                }
            }
        } else {
            GameCenterHelper.helper.endTurn(model) { error in
                defer { self.isSendingTurn = false }
                
                if let e = error {
                    print("Error ending turn: \(e)")
                    return
                }
            }
            print("Turn is ended\n____________")
        }
    }

    //Move To Views
    
    func backToStartScreen() {
        guard let viewController = viewController else {fatalError("No view controller passed to game view scene") }
        if viewController.currentScene == .main {
            viewController.switchScene()
        }
    }
    
   @objc func toggleWaitingScreen() {
       //print("IMPLEMENT THIS FEATURE")
       /*
        if waitingScreen == nil {
            waitingScreen = SKSpriteNode(imageNamed: "Waiting Label")
            self.addChild(waitingScreen!)
            waitingScreen?.position = midPoint
            waitingScreen?.size.scale(proportionateTo: .width, of: self.frame.size)
            waitingScreen?.zPosition = SpriteLevel.topLevel.rawValue + 10
        }
       waitingScreen?.isHidden = GameCenterHelper.helper.canTakeTurnForCurrentMatch
            */
    }
}
