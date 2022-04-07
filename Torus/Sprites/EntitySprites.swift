//
//  EntitySprites.swift
//  Torus Neon
//
//  Created by Moses Harding on 10/11/21.
//

import Foundation
import SpriteKit



class TorusSprite: EntitySprite {
    
    override var texture: SKTexture? {
        didSet {
            //print("Texture Changed to \(texture)")
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
    
    func disintegrate() {
        self.texture = SKTexture(imageNamed: TileAssets.disintegrateTile.rawValue)
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

class PowerListSprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: PowerConsoleAssets.powerConsole.rawValue)
        super.init(texture: texture, color: UIColor.clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameBoardSprite: EntitySprite {
    
    init(size: CGSize) {
        
        let texture = SKTexture(imageNamed: "Blank")
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TraySprite: EntitySprite {
    
    var action: (()->())? = nil
    
    init(size: CGSize, action: (()->())? = nil) {
        
        self.action = action
        
        let texture = SKTexture(imageNamed: "Tray")
        super.init(texture: texture, color: UIColor.clear, size: size)
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
