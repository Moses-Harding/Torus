//
//  TouchNode.swift
//  Torus Neon
//
//  Created by Moses Harding on 2/22/22.
//

import SpriteKit

class TouchNode: SKNode {
    typealias ActionBlock = (() -> Void)
    
    var actionBlock: ActionBlock?
    
    init(actionBlock: ActionBlock? = nil) {
        
        self.actionBlock = actionBlock
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var isEnabled: Bool = true
    
    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {
            // intentionally blank
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        if let block = actionBlock, isEnabled {
            block()
        }
    }
}

class TextNode: TouchNode {

    var label: SKLabelNode
    
    init(_ text: String, size: CGSize, actionBlock: ActionBlock? = nil) {
        
        label = SKLabelNode(text: text)
        label.fontColor = .white
        label.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - label.frame.height / 2
        )
        
        super.init(actionBlock: actionBlock)
        
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImageNode: TouchNode {

    var image: SKSpriteNode
    
    var primaryImage: String
    var secondaryImage: String?
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                isHidden = false
                self.image.texture = SKTexture(imageNamed: primaryImage)
            } else if !isEnabled {
                if let secondaryImage = secondaryImage {
                    self.image.texture = SKTexture(imageNamed: secondaryImage)
                } else {
                    isHidden = true
                }
            }
        }
    }
    
    init(_ imageNamed: String, secondaryImage: String? = nil, actionBlock: ActionBlock? = nil) {
        
        self.primaryImage = imageNamed
        self.secondaryImage = secondaryImage
        
        image = SKSpriteNode(imageNamed: primaryImage)

        super.init(actionBlock: actionBlock)
        
        addChild(image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
