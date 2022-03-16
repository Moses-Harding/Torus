//
//  File.swift
//  Triple Bomb
//
//  Created by Moses Harding on 11/23/21.
//

import Foundation
import UIKit
import GameKit

/*
class ScrollView: UIScrollView {
    
    public enum ScrollDirection {
        case vertical
        case horizontal
    }
    
    var direction: ScrollDirection
    var scene: GameScene
    
    var currentPosition = CGPoint.zero
    
    var buttonSpacer: CGFloat!
    var buttonHeight: CGFloat!
    
    init(scene: GameScene,frame: CGRect, direction: ScrollDirection = .vertical) {
        self.direction = direction
        self.scene = scene
        super.init(frame: frame)
        
        delegate = self
        
        self.showsVerticalScrollIndicator = true
        self.indicatorStyle = .white
        self.showsLargeContentViewer = true
        
        self.contentSize = CGSize(width: frame.size.width, height: frame.size.height * 0.1)
        
        currentPosition = CGPoint(x: self.frame.width / 10, y: 0)
        
        buttonSpacer = self.frame.size.height * 0.3
        buttonHeight = self.frame.size.height * 0.2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(with powerList: [PowerType:Int], from teamNumber: TeamNumber) {
        guard teamNumber == scene.model.currentTeam else { return }
        //guard GameCenterHelper.helper.canTakeTurnForCurrentMatch else { return }
        for view in subviews {
                view.removeFromSuperview()
                self.contentSize.subtract(height: buttonSpacer)
        }
        
        currentPosition = CGPoint(x: self.frame.width / 10, y: 0)
        
        for power in powerList.sorted(by: { $0.key.name < $1.key.name }) {
            add(power: power.0, powerCount: power.1)
        }
    }
    
    func add(power: PowerType, powerCount: Int) {
        
        let buttonFrame = CGRect(origin: currentPosition, size: self.frame.size.scaled(x: 0.5, y: 0.2))
        let button = ScrollButton(frame: buttonFrame, scrollView: self, power: power, powerCount: powerCount)
        self.addSubview(button)
        
        currentPosition = CGPoint(x: currentPosition.x, y: currentPosition.y + buttonSpacer)
        
        self.contentSize.add(height: buttonSpacer)
    }
    
    func buttonPushed(_ power: PowerType) {
        scene.gameManager.activate(power: power)
    }
    
    func clear() {
        self.updateView(with: [:], from: TeamNumber.one)
    }
}

extension ScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if direction == .vertical {
            print(scrollView.contentOffset.y)
        } else {
            print(scrollView.contentOffset.x)
        }
    }
}

class ScrollButton: UIButton {
    
    var power: PowerType
    var scrollView: ScrollView
    
    init(frame: CGRect, scrollView: ScrollView, power: PowerType, powerCount: Int) {
        self.power = power
        self.scrollView = scrollView
        super.init(frame: frame)
        
        self.setTitle("\(power.name) x \(powerCount)", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.textAlignment = .left
        self.contentHorizontalAlignment = .left
        self.titleLabel?.font = UIFont(name: "Courier", size: 20)
        
        self.titleLabel?.minimumScaleFactor = 0.5
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //self.layer.borderColor = UIColor.white.cgColor
        //self.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollView.buttonPushed(power)
    }
}
*/
