//
//  Sprites.swift
//  Triple Bomb
//
//  Created by Moses Harding on 9/27/21.
//

import Foundation
import SpriteKit
import UIKit

class MoveSelectionOverlay: OverlaySprite {
    
    init(size: CGSize, tileHeight: TileHeight, moveType: MoveType, parentSprite: EntitySprite) {
        
        var textureName: String
        
        let heightNum = String(tileHeight.rawValue + 3)
        let tileName = "Tile - L" + heightNum
        
        switch moveType {
        case .normal:
            textureName = tileName + " - Selected"
        default:
            textureName = tileName + " - Attack"
        }
        
        super.init(primaryTexture: SKTexture(imageNamed: textureName), color: UIColor.white, size: size, parentSprite: parentSprite)
        
        self.zPosition = SpriteLevel.tileOverlay.rawValue
        animateSelection()
    }
    
    func animateSelection() {
        
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.75)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.75)
        let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
        
        run(SKAction.repeatForever(fadeSequence))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class OrbOverlay: OverlaySprite {
    
    init(parentSize: CGSize, parentSprite: EntitySprite) {
        
        let textureName = OrbAsset.allCases.randomElement()?.rawValue ?? "Orb-1"
        let size = CGSize(width: parentSize.width * 0.5, height: parentSize.width * 0.5)
        
        super.init(primaryTexture: SKTexture(imageNamed: textureName), color: UIColor.white, size: size, parentSprite: parentSprite)
        
        self.zPosition = SpriteLevel.tileOverlay.rawValue
        
        animateSelection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateSelection() {
        
        let rotate = SKAction.rotate(byAngle: 0.2, duration: 0.3)
        
        run(SKAction.repeatForever(rotate))
    }
}
