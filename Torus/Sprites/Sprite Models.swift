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
        if blend { self.colorBlendFactor = 1 }
    }
    
    func addToParent() {
        self.parentSprite.addChild(self)
    }
    
    func switchTextures() {
        
        self.texture = isPrimary ? secondaryTexture : primaryTexture
        
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

