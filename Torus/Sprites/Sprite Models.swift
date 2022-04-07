//
//  EntitySpriteModel.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/12/21.
//

import Foundation
import SpriteKit

class EntitySprite: SKSpriteNode {
    
    var parentEntity: Entity?
    override var isUserInteractionEnabled: Bool {
        set {
            //
        }
        get {
            return true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let parentEntity = parentEntity else {
            fatalError("No parent entity")
        }
        parentEntity.wasTouched()
    }
}

class OverlaySprite: SKSpriteNode {
    
    var parentSprite: EntitySprite
    
    var primaryTexture: SKTexture
    var secondaryTexture: SKTexture?
    var isPrimary = true
    
    init(primaryTexture: SKTexture, secondaryTexture: SKTexture? = nil, color: UIColor, blend: Bool = false, size: CGSize, parentSprite: EntitySprite, touchEnabled: Bool = false) {
        
        self.parentSprite = parentSprite
        self.primaryTexture = primaryTexture
        self.secondaryTexture = secondaryTexture
        
        super.init(texture: primaryTexture, color: color, size: size)
        
        self.zPosition = parentSprite.zPosition + 1
        
        addToParent()
        if blend { self.colorBlendFactor = 1 }
        if touchEnabled { self.isUserInteractionEnabled = true }
    }
    
    func addToParent() {
        self.parentSprite.addChild(self)
    }
    
    func switchTextures() {
        
        if isPrimary {
            self.texture = secondaryTexture
        } else {
            self.texture = primaryTexture
        }
        
        isPrimary = !isPrimary
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LabelSprite: SKLabelNode {
    
    var parentSprite: SKSpriteNode
    var action: (()->())?
    
    init(parentSprite: SKSpriteNode, fontName: String = "Courier-Bold", position: CGPoint? = nil, text: String? = nil, width: CGFloat? = nil, action: (()->())? = nil) {
        
        self.action = action
        
        self.parentSprite = parentSprite
        
        super.init()
        
        self.text = text ?? "Blank"
        self.position = position ?? CGPoint.zero
        
        isUserInteractionEnabled = true
        
        if let width = width {
            self.preferredMaxLayoutWidth = width
            self.numberOfLines = -1
            self.lineBreakMode = .byCharWrapping
        }
        
        self.verticalAlignmentMode = .center
        self.zPosition = parentSprite.zPosition + 1
        
        self.fontName = fontName
        
        addToParent()
    }
    
    func addToParent() {
        self.parentSprite.addChild(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let action = action {
            action()
        }
    }
}

class TrayItemSprite: SKSpriteNode {
    
    var parentSprite: OverlaySprite
    var action: (()->())?
    
    var primaryTexture: SKTexture
    var secondaryTexture: SKTexture?
    var isPrimary = true
    
    init(primaryTexture: SKTexture, secondaryTexture: SKTexture? = nil, color: UIColor, blend: Bool = false, size: CGSize, parentSprite: OverlaySprite, action: (()->())? = nil) {
        
        self.action = action
        
        self.parentSprite = parentSprite
        self.primaryTexture = primaryTexture
        self.secondaryTexture = secondaryTexture
        
        super.init(texture: primaryTexture, color: color, size: size)
        
        self.zPosition = parentSprite.zPosition + 1
        
        addToParent()
        if blend {
            self.colorBlendFactor = 1
        }
    }
    
    func addToParent() {
        self.parentSprite.addChild(self)
    }
    
    func switchTextures() {
        
        if isPrimary {
            self.texture = secondaryTexture
        } else {
            self.texture = primaryTexture
        }
        
        isPrimary = !isPrimary
    }
    
    func setPrimaryTexture() {
        self.texture = primaryTexture
        isPrimary = true
    }
    
    func setSecondaryTexture() {
        self.texture = secondaryTexture
        isPrimary = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let action = action {
            action()
        }
    }
}

class UserMessage: SKNode {
    typealias ActionBlock = (() -> ())
    
    var actionBlock: ActionBlock
    var label: SKLabelNode
    var background: SKShapeNode
    
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
        //self.background = SKSpriteNode(texture: SKTexture.pillBackgroundTexture(of: size, color: nil), color: UIColor.clear, size: size)
        self.label = SKLabelNode(text: text)
        
        label.preferredMaxLayoutWidth = size.width
        label.numberOfLines = -1
        label.lineBreakMode = .byCharWrapping
        label.zPosition = SpriteLevel.userMessage.rawValue
        label.fontName = fontName
        label.verticalAlignmentMode = .center
        if let fontSize = fontSize { label.fontSize = fontSize }
        
        self.background = SKShapeNode(rectOf: label.frame.size.scaled(by: 1.05), cornerRadius: 10)
        background.fillColor = UIColor(red: 0.99, green: 0.01, blue: 0.48, alpha: 1.00)
        background.zPosition = SpriteLevel.userMessage.rawValue
        background.glowWidth = 7
        background.strokeColor = UIColor(red: 0.99, green: 0.01, blue: 0.48, alpha: 1.00)
        
        super.init()
        
        self.addChild(self.background)
        self.addChild(self.label)
        
        parent.addChild(self)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func autoDismiss() {
        self.run(SKAction.wait(forDuration: 0.2)) { self.removeFromParent() }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionBlock()
        autoDismiss()
    }
}
