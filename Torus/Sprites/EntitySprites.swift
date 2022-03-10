//
//  EntitySprites.swift
//  Triple Bomb
//
//  Created by Moses Harding on 10/11/21.
//

import Foundation
import SpriteKit



class TorusSprite: EntitySprite {
    
    override var texture: SKTexture? {
        didSet {
            print("Texture Changed to \(texture)")
        }
    }

    init(textureName: String, size: CGSize) {
        
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: UIColor.clear, size: size.scaled(by: 0.75))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let parent = parentEntity else {
            fatalError("No Parent Entity")
        }
        parent.wasTouched()
    }
}

class TileSprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: TileAssets.l3.rawValue)

        super.init(texture: texture, color: UIColor.clear, size: size)
    }
    
    func acid() {
        self.texture = SKTexture(imageNamed: TileAssets.acidTile.rawValue)
    }
    
    func changeHeight(to height: TileHeight) {
        
        switch height {
        case .l1:
            self.texture = SKTexture(imageNamed: TileAssets.l1.rawValue)
        case .l2:
            self.texture = SKTexture(imageNamed: TileAssets.l2.rawValue)
        case .l3:
            self.texture = SKTexture(imageNamed: TileAssets.l3.rawValue)
        case .l4:
            self.texture = SKTexture(imageNamed: TileAssets.l4.rawValue)
        case .l5:
            self.texture = SKTexture(imageNamed: TileAssets.l5.rawValue)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameBoardSprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: "Blank")
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        //self.colorBlendFactor = 1
        //self.alpha = 0
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TraySprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: "Tray")
        super.init(texture: texture, color: UIColor.clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayScreenSprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: "Blank")
        super.init(texture: texture, color: UIColor.clear, size: size)

        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ButtonTraySprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: "Blank")
        super.init(texture: texture, color: UIColor.black, size: size)
        
        self.colorBlendFactor = 1.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
