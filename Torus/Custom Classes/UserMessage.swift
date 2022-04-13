//
//  UserMessage.swift
//  Torus
//
//  Created by Moses Harding on 4/12/22.
//

import Foundation
import SpriteKit

class UserMessage: SKNode {
    typealias ActionBlock = (() -> ())
    
    var actionBlock: ActionBlock
    var label: SKLabelNode
    var background: SKShapeNode!
    
    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {
            //
        }
    }
    
    init(_ text: String, fontName: String = "KohinoorDevanagari-Medium", fontSize: CGFloat? = nil, size: CGSize, parent: SKNode, position: CGPoint, actionBlock: ActionBlock? = nil) {
        
        self.actionBlock = actionBlock ?? { print("Message to user - \(text)") }
        self.label = SKLabelNode(text: text)
        
        label.preferredMaxLayoutWidth = size.width
        label.numberOfLines = -1
        label.lineBreakMode = .byCharWrapping
        label.zPosition = SpriteLevel.userMessage.rawValue
        label.fontName = fontName
        label.verticalAlignmentMode = .center
        if let fontSize = fontSize { label.fontSize = fontSize }
        
        super.init()
        
        setBackground()
        
        self.addChild(self.background)
        self.addChild(self.label)
        
        parent.addChild(self)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeText(to text: String) {
        self.label.text = text

        setBackground()
        self.addChild(background)
    }
    
    func clear() {
        label.text = ""
        background.removeFromParent()
    }
    
    func setBackground() {
        background = SKShapeNode(rectOf: label.frame.size.scaled(by: 1.05), cornerRadius: 10)
        background.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        background.zPosition = SpriteLevel.userMessage.rawValue
        background.glowWidth = 1
        background.strokeColor = UIColor(red: 0.99, green: 0.01, blue: 0.48, alpha: 0.5)
    }
    
    func autoDismiss() {
        self.run(SKAction.wait(forDuration: 0.2)) { self.removeFromParent() }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionBlock()
        autoDismiss()
    }
}
