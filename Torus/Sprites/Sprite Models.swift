//
//  EntitySpriteModel.swift
//  Triple Bomb
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
    
    init(parentSprite: SKSpriteNode, fontName: String = "Courier-Bold", position: CGPoint? = nil, text: String? = nil, width: CGFloat? = nil) {
        
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
        print(self.text as? String)
    }
}

class TrayItemSprite: SKSpriteNode {
    
    var parentSprite: OverlaySprite
    
    var primaryTexture: SKTexture
    var secondaryTexture: SKTexture?
    var isPrimary = true
    
    init(primaryTexture: SKTexture, secondaryTexture: SKTexture? = nil, color: UIColor, blend: Bool = false, size: CGSize, parentSprite: OverlaySprite) {
        
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
}

class UserMessage: SKNode {
    typealias ActionBlock = (() -> ())
    
    var actionBlock: ActionBlock
    var label: LabelSprite
    var background: SKSpriteNode
    
    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {
            //
        }
    }
    
    init(_ text: String, size: CGSize, actionBlock: ActionBlock?) {
        
        self.actionBlock = actionBlock ?? { print("Message to user - \(text)") }
        self.background = SKSpriteNode(texture: SKTexture.pillBackgroundTexture(of: size, color: nil), color: UIColor.clear, size: size)
        self.label = LabelSprite(parentSprite: self.background, text: text)
        
        super.init()
        
        self.addChild(self.background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func autoDismiss() {
        self.run(SKAction.wait(forDuration: 5)) { self.removeFromParent() }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        actionBlock()
    }
}
