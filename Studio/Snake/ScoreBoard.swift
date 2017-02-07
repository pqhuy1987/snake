//
//  ScoreBoard.swift
//  Snake
//
//  Created by Alexander Pagliaro on 12/8/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import UIKit
import SpriteKit

class ScoreBoard: SKNode {
    
    var score : Int = 0
    var scoreLabel : SKLabelNode!
    let hiScoreLabel = SKLabelNode(fontNamed: "04b03")
    var fontSize = CGFloat(32.0)
   
    override init() {
        super.init()
        
        scoreLabel = SKLabelNode(fontNamed: "04b03")
        scoreLabel.fontSize = fontSize
        scoreLabel.fontColor = UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        self.addChild(scoreLabel)
        
        hiScoreLabel.text = "Hi Score"
        hiScoreLabel.fontSize = 12
        hiScoreLabel.position = CGPoint(x: 0, y: fontSize-4)
        hiScoreLabel.fontColor = UIColor.blackColor()
        hiScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        self.addChild(hiScoreLabel)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func displayHiScore(score: Int) {
        hiScoreLabel.hidden = false
        scoreLabel.text = stringFromScore(score)
    }
    
    func reset() {
        hiScoreLabel.hidden = true
        score = 0
        scoreLabel.text = stringFromScore(score)
        updatePhysicsBody()
        
    }
    
    func updatePhysicsBody() {
        
        let size = self.calculateAccumulatedFrame().size
        let physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width*2, height: size.height*2))
        physicsBody.categoryBitMask = PhysicsCategory.None.rawValue
        physicsBody.dynamic = false
        
        self.physicsBody = physicsBody
        
    }
    
    func addToScore(points: Int) {
        
        // Set score label
        score += points
        scoreLabel.text = stringFromScore(score)
        
        updatePhysicsBody()
        
    }
    
    func stringFromScore(score : Int) -> String {
        
        return String(format: "%04d", score)
        
    }
    
}
