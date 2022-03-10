//
//  TouchNode.swift
//  Torus
//
//  Created by Moses Harding on 2/22/22.
//

import SpriteKit

class TouchNode: SKNode {
    typealias ActionBlock = (() -> Void)
    
    var actionBlock: ActionBlock?
    var label: SKLabelNode
    
    init(_ text: String, size: CGSize, actionBlock: ActionBlock? = nil) {
        
        self.actionBlock = actionBlock
        
        label = SKLabelNode(text: text)
        label.fontColor = .white
        label.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - label.frame.height / 2
        )
        
        super.init()
        
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {
            // intentionally blank
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let block = actionBlock, isEnabled {
            block()
        }
    }
}
