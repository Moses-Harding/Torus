//
//  PowerList.swift
//  Torus Neon
//
//  Created by Moses Harding on 3/14/22.
//

import Foundation
import SpriteKit

class PowerList: Entity {
    
    var currentPosition = CGPoint.zero
    
    var buttonSpacer: CGFloat!
    var buttonHeight: CGFloat!
    var buttonWidth: CGFloat!
    
    var widthScale = 0.65
    
    var cropNode = SKCropNode()
    
    var midPoint: CGPoint {
        return CGPoint(x: sprite.frame.midX, y: sprite.frame.midY)
    }
    
    var baseX: CGFloat!
    var baseY: CGFloat!
    
    var upArrow: ImageNode!
    var downArrow: ImageNode!
    
    var powerIsActivating = false
    
    var powerButtons: [PowerButton] = [] {
        didSet {
            if totalPowerButtonHeight >= sprite.frame.height {
                upArrow.isHidden = false
                downArrow.isHidden = false
            } else {
                upArrow.isHidden = true
                downArrow.isHidden = true
            }
        }
    }
    
    var totalPowerButtonHeight: CGFloat {
        CGFloat(powerButtons.count + 1) * buttonSpacer
    }
    var start: PowerButton? {
        return powerButtons.first
    }
    var end: PowerButton? {
        return powerButtons.last
    }
    
    var scrollPos: CGFloat = 0
    var scrollDistance: CGFloat {
        sprite.frame.height / 2
    }
    
    init(scene: GameScene, position: CGPoint, size: CGSize) {

        let sprite = PowerListSprite(size: size)

        super.init(scene: scene, sprite: sprite, position: position, spriteLevel: .torusOrScrollView, name: PowerConsoleAssets.powerConsole.rawValue, size: size)
        
        buttonSpacer = sprite.frame.size.height * 0.2
        buttonHeight = sprite.frame.size.height * 0.15
        buttonWidth = sprite.frame.size.width * widthScale
        
        upArrow = ImageNode("Arrow - Up") { self.scrollUp() }
        downArrow = ImageNode("Arrow - Down") { self.scrollDown() }

        cropNode.zPosition = sprite.zPosition + 1
        sprite.addChild(cropNode)
        
        baseX = -sprite.size.width / 2.5
        baseY = (sprite.size.height / 2) - buttonHeight - (buttonHeight / 2)

        let testSprite = SKSpriteNode(imageNamed: "Blank")
        testSprite.size = size.scaled(x: 1, y: 0.9)
        cropNode.maskNode = testSprite
        
        sprite.addChild(upArrow)
        sprite.addChild(downArrow)
        
        let height = sprite.frame.size.height * 0.25
        let testSize = CGSize(width: 0, height: height)
        
        upArrow.image.size.scale(proportionateTo: .height, of: testSize)
        downArrow.image.size.scale(proportionateTo: .height, of: testSize)
        
        upArrow.position = CGPoint(x: (sprite.frame.width / 2) - upArrow.image.size.width, y: upArrow.image.size.height)
        downArrow.position = CGPoint(x: upArrow.position.x, y: -upArrow.image.size.height)
        
        upArrow.zPosition = sprite.zPosition + 1
        downArrow.zPosition = sprite.zPosition + 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func updateView(with powerList: [PowerType:Int], from torus: Torus? = nil, calledBy: String) {
        
        if TestingManager.helper.verbosePowerList {
            print("Updating powerlist view with \(String(describing: torus)) at \(String(describing: torus?.currentTile))")
        }
        
        scrollPos = 0
        
        powerButtons.forEach { $0.removeFromParent() }
        powerButtons = []
        
        currentPosition = CGPoint(x: baseX, y: baseY)

        for power in powerList.sorted(by: { $0.key.name < $1.key.name }) {
            powerButtons.append(add(power: power.0, powerCount: power.1))
        }

        if totalPowerButtonHeight >= sprite.frame.height {
            upArrow.isHidden = false
            downArrow.isHidden = false
        } else {
            upArrow.isHidden = true
            downArrow.isHidden = true
        }
    }
    
    //@discardableResult
    func add(power: PowerType, powerCount: Int) -> PowerButton {
        
        let buttonFrame = CGRect(origin: currentPosition, size: sprite.frame.size.scaled(x: widthScale, y: 0.2))
        let button = PowerButton(powerList: self, power: power, cropNode: cropNode, powerCount: powerCount, position: currentPosition, buttonFrame: buttonFrame)
        cropNode.addChild(button)

        currentPosition = CGPoint(x: currentPosition.x, y: currentPosition.y - buttonSpacer)

        return button
    }
    
    func buttonPushed(_ button: PowerButton) {
        
        guard let (duration, isEffective, closure) = scene.gameManager.activate(power: button.power) else {
            print("PowerList - ButtonPushed - Duration and closure not received")
            return
        }

        if TestingManager.helper.verbosePowerList { print("Activating \(String(describing: button.label.text)) with duration \(duration)") }
        
        guard isEffective else {
            self.displayPowerConsole(message: .noEffect, calledBy: "PowerList - ButtonPushed - Power Not Effective")
            return
        }
        
        powerIsActivating = true
        
        button.label.fontColor = UIColor(red: 0.88, green: 0.44, blue: 1.00, alpha: 1.00)
        button.label.fontName = "Courier-Bold"
        button.label.fontSize = 16
        
        let gateSprite = SKSpriteNode(imageNamed: PowerConsoleAssets.filled.rawValue)
        self.sprite.addChild(gateSprite)
        gateSprite.size = self.sprite.size
        gateSprite.alpha = 0.5
        gateSprite.zPosition = 20

        let waitDuration = duration > 0.5 ? duration : 0.5
        
        self.sprite.run(SKAction.wait(forDuration: waitDuration + 0.1)) {
            self.powerIsActivating = false
            closure()
            gateSprite.removeFromParent()
            if self.manager.currentTeam.currentlySelected == nil {
                self.clear()
            }
        }
    }
    
    func clear() {
        self.updateView(with: [:], calledBy: "Clearing view")
    }
    
    func displayPowerConsole(message: PowerConsoleAssets, duration: CGFloat = 0.75, calledBy: String) {
        
        if TestingManager.helper.verbosePowerList { print("Display \(message.rawValue) called by \(calledBy)") }
        
        let gateSprite = SKSpriteNode(imageNamed: message.rawValue)
        self.sprite.addChild(gateSprite)
        gateSprite.size = self.sprite.size
        gateSprite.zPosition = 20
        self.sprite.run(SKAction.wait(forDuration: duration)) {
            gateSprite.removeFromParent()
        }
    }
    
    func scrollUp() {

        guard scrollPos > 0 else { return }
        
        powerButtons.forEach { $0.run(SKAction.moveBy(x: 0, y: -sprite.frame.height / 2, duration: 0.1)) }
        
        scrollPos -= scrollDistance
    }
    
    func scrollDown() {
        
        guard (scrollPos + sprite.size.height) < totalPowerButtonHeight else { return }
        
        powerButtons.forEach { $0.run(SKAction.moveBy(x: 0, y: sprite.frame.height / 2, duration: 0.1)) }
        
        scrollPos += scrollDistance
    }
}

class PowerButton: TouchNode {
    
    var power: PowerType
    var powerList: PowerList
    var label: SKLabelNode
    var background: SKShapeNode
    var highlight: SKSpriteNode
    
    init(powerList: PowerList, power: PowerType, cropNode: SKCropNode, powerCount: Int, position: CGPoint, buttonFrame: CGRect) {
        self.power = power
        self.powerList = powerList
        
        background = SKShapeNode(rect: buttonFrame, cornerRadius: 2)
        background.strokeColor = .clear
        
        highlight = SKSpriteNode(texture: SKTexture(imageNamed: "Blank"), size: background.frame.size)
        self.label = SKLabelNode()
        
        super.init(actionBlock: nil)
        
        self.addChild(background)

        background.addChild(label)
        
        highlight.position = background.position
        
        label.text = "\(power.name) x \(powerCount)"
        label.position = position
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.preferredMaxLayoutWidth = buttonFrame.width
        label.fontName = "Courier"
        label.fontSize = 12
        label.zPosition = background.zPosition + 1
        label.fontColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard !powerList.powerIsActivating else { return }

        powerList.buttonPushed(self)
    }
}
