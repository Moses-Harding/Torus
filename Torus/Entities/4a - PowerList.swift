//
//  PowerList.swift
//  Torus
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
    
    var powerButtons: [PowerButton] = [] {
        didSet {
            print(totalPowerButtonHeight, sprite.frame.height)
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

        super.init(scene: scene, sprite: sprite, position: position, spriteLevel: .torusOrScrollView, name: TraySpriteAssets.redTextBox.rawValue, size: size)
        
        buttonSpacer = sprite.frame.size.height * 0.2
        buttonHeight = sprite.frame.size.height * 0.15
        buttonWidth = sprite.frame.size.width * widthScale
        
        upArrow = ImageNode("Arrow - Up") { self.scrollUp() }
        downArrow = ImageNode("Arrow - Down") { self.scrollDown() }
        
        //currentPosition = CGPoint(x: sprite.frame.midX, y: sprite.frame.midY)
        //cropNode.position = CGPoint(x: 0, y: 100)
        cropNode.zPosition = sprite.zPosition + 1
        sprite.addChild(cropNode)
        
        baseX = -sprite.size.width / 2.5
        baseY = (sprite.size.height / 2) - buttonHeight - (buttonHeight / 2)

        //let maskNode = SKSpriteNode(imageNamed: TraySpriteAssets.redTextBox.rawValue)
        //maskNode.size = size

        let testSprite = SKSpriteNode(imageNamed: "Blank")
        testSprite.size = size.scaled(x: 1, y: 0.9)
        cropNode.maskNode = testSprite
        
        //let redLabelBackground = SKSpriteNode(imageNamed: BackgroundLabelAsset.redHighlighted.rawValue)
        //redLabelBackground.size = sprite.size.scaled(by: 0.5)

        
        //let testSprite = SKSpriteNode(imageNamed: TraySpriteAssets.redTextBox.rawValue)
        //cropNode.addChild(redLabelBackground)
        //testSprite.zPosition = 1
        
        //sprite.addChild(testSprite)
        
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
    

    func updateView(with powerList: [PowerType:Int], from teamNumber: TeamNumber) {
        guard teamNumber == scene.model.currentTeam else { return }
        //guard GameCenterHelper.helper.canTakeTurnForCurrentMatch else { return }
        
        powerButtons.forEach { $0.removeFromParent() }
        powerButtons = []
        
        currentPosition = CGPoint(x: baseX, y: baseY)
        /*
        //currentPosition = CGPoint(x: sprite.frame.midX, y: sprite.frame.midY)
        var smallestPowerSize: CGFloat = 100
        
        for power in powerList.sorted(by: { $0.key.name < $1.key.name }) {
            let newSize = add(power: power.0, powerCount: power.1)
            smallestPowerSize = smallestPowerSize < newSize ? smallestPowerSize : newSize
        }
        */
        for power in powerList.sorted(by: { $0.key.name < $1.key.name }) {
            powerButtons.append(add(power: power.0, powerCount: power.1))
        }
        
        /*
        for child in cropNode.children {
            let button = child as? PowerButton
            button?.label.fontSize = smallestPowerSize
        }
         */

        
        if totalPowerButtonHeight >= sprite.frame.height {
            upArrow.isHidden = false
            downArrow.isHidden = false
        } else {
            upArrow.isHidden = true
            downArrow.isHidden = true
        }
    }
    
    //@discardableResult
    func add(power: PowerType, powerCount: Int) -> PowerButton {//-> CGFloat {
        
        let buttonFrame = CGRect(origin: currentPosition, size: sprite.frame.size.scaled(x: widthScale, y: 0.2))
        let button = PowerButton(powerList: self, power: power, cropNode: cropNode, powerCount: powerCount, position: currentPosition, buttonFrame: buttonFrame)
        cropNode.addChild(button)
        //self.addSubview(button)
        //sprite.addChild(button)
        
        currentPosition = CGPoint(x: currentPosition.x, y: currentPosition.y - buttonSpacer)
        
       // self.contentSize.add(height: buttonSpacer)
        //return button.label.fontSize
        return button
    }
    
    func buttonPushed(_ button: PowerButton) {
        
        guard let (duration, closure) = scene.gameManager.activate(power: button.power) else {
            print("PowerLIst - ButtonPushed - Duration and closure not received")
            return }
        
        let flashRed = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.1)
        let clearRed = SKAction.colorize(with: .clear, colorBlendFactor: 1, duration: 0.1)
        let sequence = SKAction.sequence([flashRed, clearRed])
        let repeating = SKAction.repeatForever(sequence)
        
        print(duration, closure)
        button.background.run(repeating)
        button.background.run(SKAction.wait(forDuration: duration)) {
            closure()
        }
    }
    
    func clear() {
        self.updateView(with: [:], from: TeamNumber.one)
    }
    
    func scrollUp() {

        guard scrollPos > 0 else { return }
        
        powerButtons.forEach { $0.run(SKAction.moveBy(x: 0, y: -sprite.frame.height / 2, duration: 0.1)) }
        
        scrollPos -= sprite.frame.height / 2
        
        print(scrollPos, totalPowerButtonHeight)
    }
    
    func scrollDown() {
        
        print("Scroll down")
        
        guard abs(scrollPos + scrollDistance) < totalPowerButtonHeight else { return }
        
        powerButtons.forEach { $0.run(SKAction.moveBy(x: 0, y: sprite.frame.height / 2, duration: 0.1)) }
        
        scrollPos += sprite.frame.height / 2
        
        print(scrollPos, totalPowerButtonHeight)
    }
}

class PowerButton: TouchNode {
    
    var power: PowerType
    var powerList: PowerList
    var label: SKLabelNode
    //var background: SKSpriteNode
    var background: SKShapeNode
    
    init(powerList: PowerList, power: PowerType, cropNode: SKCropNode, powerCount: Int, position: CGPoint, buttonFrame: CGRect) {
        self.power = power
        self.powerList = powerList
        
        //self.background = SKSpriteNode(color: .clear, size: self.powerList.sprite.size.scaled(x: 0.5, y: 0.2))
        background = SKShapeNode(rect: buttonFrame, cornerRadius: 2)
        background.strokeColor = .clear
        //background.position = position
        self.label = SKLabelNode()
        
        super.init(actionBlock: nil)
        
        self.addChild(background)

        background.addChild(label)
        
        label.text = "\(power.name) x \(powerCount)"
        label.position = position
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        //self.isUserInteractionEnabled = true
        label.preferredMaxLayoutWidth = buttonFrame.width
        label.fontName = "Courier"
        label.fontSize = 14
        label.zPosition = 20
        label.color = .white
        
        //label.numberOfLines = -1
        //label.lineBreakMode = .byCharWrapping
        //label.zPosition = cropNode.zPosition + 1
        //label.fontName = "Courier"

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        powerList.buttonPushed(self)
    }
}
