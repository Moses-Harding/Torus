//
//  Extensions.swift
//  Torus Neon
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

extension Int {
    func asTwoDigitNumber() -> String {
        if self / 10 >= 1 {
            return String(self)
        } else {
            return "0\(self)"
        }
    }
}

extension UIColor {
    
    static func convertSCSS(_ string: String) -> [UIColor] {
        
        var colors = [UIColor]()
        
        let lines = string.split(separator: ";")
        
        for line in lines {
            var colorNumbers = [CGFloat]()
            let second = line.split(separator: "(")[1]
            let secondItems = second.split(separator: ",")
            for eachItem in secondItems {
                var number = eachItem
                number.removeAll { $0 == ")" || $0 == " " }
                colorNumbers.append(CGFloat(Int(number) ?? 0))
            }
            let color = UIColor(red: colorNumbers[0] / 256, green: colorNumbers[1] / 256, blue: colorNumbers[2] / 256, alpha: colorNumbers[3])
            colors.append(color)
        }
        
        return colors
    }

    static func rgba(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Int) -> UIColor {
        return UIColor(red: CGFloat(red) / 256, green: CGFloat(green) / 256, blue: CGFloat(blue) / 256, alpha: CGFloat(alpha))
    }
}
