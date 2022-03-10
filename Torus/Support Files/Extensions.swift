//
//  Extensions.swift
//  Triple Bomb
//
//  Created by Moses Harding on 11/15/21.
//

import SpriteKit

extension CGSize {
    
    func scaled(by float: CGFloat) -> CGSize {
        return self.applying(.init(scaleX: float, y: float))
    }
    
    func scaled(x: CGFloat, y: CGFloat) -> CGSize {
        return self.applying(.init(scaleX: x, y: y))
    }
    
    mutating func add(width: CGFloat = 0, height: CGFloat = 0) {
        self = CGSize(width: self.width + width, height: self.height + height)
    }
    
    mutating func subtract(width: CGFloat = 0, height: CGFloat = 0) {
        self = CGSize(width: self.width - width, height: self.height - height)
    }
}

extension CGPoint {
    
    func move(_ direction: MovePointDirection, by points: CGFloat) -> CGPoint {
        
        var x = self.x
        var y = self.y
        
        switch direction {
        case .up:
            y += points
        case .down:
            y -= points
        case .right:
            x += points
        case .left:
            x -= points
        }
        
        return CGPoint(x: x, y: y)
    }
}

extension Bool {
    
    mutating func switchState() {
        self.toggle()
    }
}

extension SKTexture {
    class func pillBackgroundTexture(of size: CGSize, color: UIColor?) -> SKTexture {
      return SKTexture(image: UIGraphicsImageRenderer(size: size).image { context in
        let fillColor = color ?? .white
        let shadowColor = UIColor(white: 0, alpha: 0.3)
        
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 5
        
        let drawContext = context.cgContext
        
        let pillRect = CGRect(origin: .zero, size: size).insetBy(dx: 3, dy: 4)
        let rectanglePath = UIBezierPath(roundedRect: pillRect, cornerRadius: size.height / 2)
        
        drawContext.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: shadowColor.cgColor)
        fillColor.setFill()
        rectanglePath.fill()
      })
    }
}
