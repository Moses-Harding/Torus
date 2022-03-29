//
//  Extensions.swift
//  Triple Bomb
//
//  Created by Moses Harding on 11/15/21.
//

import SpriteKit


extension Array where Element: Equatable {
    
    mutating func appendIfUnique(_ item: Element) {
        if !self.contains(where: { $0 == item }) {
            self.append(item)
        }
    }
}


enum ScaleDirection {
    case width, height
}

extension CGSize {
    
    func scaled(by float: CGFloat) -> CGSize {
        return self.applying(.init(scaleX: float, y: float))
    }
    
    func scaled(x: CGFloat, y: CGFloat) -> CGSize {
        return self.applying(.init(scaleX: x, y: y))
    }
    
    mutating func scale(proportionateTo direction: ScaleDirection, of size: CGSize) {
        let currentWidth = self.width
        let currentHeight = self.height
        let otherWidth = size.width
        let otherHeight = size.height
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if direction == .width {
            newWidth = otherWidth
            let ratio = newWidth / currentWidth
            newHeight = currentHeight * ratio
        } else {
            newHeight = otherHeight
            let ratio = newHeight / currentHeight
            newWidth = currentWidth * ratio
        }
        
        self = CGSize(width: newWidth, height: newHeight)
    }
    
    mutating func scale(proportionateTo direction: ScaleDirection, with dimension: CGFloat) {
        let currentWidth = self.width
        let currentHeight = self.height
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if direction == .width {
            newWidth = dimension
            let ratio = newWidth / currentWidth
            newHeight = currentHeight * ratio
        } else {
            newHeight = dimension
            let ratio = newHeight / currentHeight
            newWidth = currentWidth * ratio
        }
        
        self = CGSize(width: newWidth, height: newHeight)
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


extension SKLabelNode {
    func adjustLabelFontSizeToFitRect(rect:CGRect) {
        
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / self.frame.width, rect.height / self.frame.height)
        
        // Change the fontSize.
        self.fontSize *= scalingFactor
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        //self.position = CGPoint(x: rect.midX, y: rect.midY - self.frame.height / 2.0)
    }
}

extension Int {
    func asTwoDigitNumber() -> String {
        if self / 10 >= 1 {
            return String(self)
        } else {
            return "0\(self)"
        }
    }
}
