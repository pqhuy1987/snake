//
//  Wall.swift
//  Snake
//
//  Created by Alexander Pagliaro on 12/9/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import UIKit
import SpriteKit

class Wall: SKSpriteNode {
   
    init(size: CGSize, inverted: Bool) {
        super.init(texture: nil, color: UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0), size: size)
        
        // Set up edge physics body
        var edgeStartPoint : CGPoint = CGPoint.zero
        var edgeEndPoint : CGPoint = CGPoint.zero
        
        // If horizontal wall and non inverted
        if (size.width >= size.height && !inverted) {
            edgeStartPoint = CGPoint(x: -size.width/2.0, y: 0)
            edgeEndPoint = CGPoint(x: size.width/2.0, y: 0)
        }
        
        // Horizontal wall, inverted
        if (size.width >= size.height && inverted) {
            edgeStartPoint = CGPoint(x: -size.width/2.0, y: size.height)
            edgeEndPoint = CGPoint(x: size.width/2.0, y: size.height)
        }
        
        // Vertical wall and non inverted
        if (size.width < size.height && !inverted) {
            edgeStartPoint = CGPoint(x: 0, y: -size.height/2.0)
            edgeEndPoint = CGPoint(x: 0, y: size.height/2.0)
        }
        
        // Vertical wall and inverted
        if (size.width < size.height && inverted) {
            edgeStartPoint = CGPoint(x: size.width, y: -size.height/2.0)
            edgeEndPoint = CGPoint(x: size.width, y: size.height/2.0)
        }
        
        let physicsBody = SKPhysicsBody(edgeFrom: edgeStartPoint, to: edgeEndPoint)
        
        physicsBody.categoryBitMask = PhysicsCategory.wall.rawValue
        physicsBody.collisionBitMask = PhysicsCategory.food.rawValue | PhysicsCategory.snake.rawValue
        //physicsBody.contactTestBitMask = PhysicsCategory.Snake.rawValue
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.friction = 0.1
        physicsBody.restitution = 0.5
        //physicsBody.dynamic = false
        
        self.physicsBody = physicsBody
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
