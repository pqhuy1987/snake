//
//  Food.swift
//  Snake
//
//  Created by Alexander Pagliaro on 11/25/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import SpriteKit

class Food: SKSpriteNode, PhysicsScaling {
    
    private struct ClassVariables {
        static var physicsScalingFactor : CGFloat = CGFloat(1.0)
    }
   
    convenience init(rectOfSize size: CGSize) {
        
        self.init(color: UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0), size: size)
        
        //self.size = size
        //self.color =
        
        let physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody.mass = 1.0
        physicsBody.allowsRotation = false
        physicsBody.collisionBitMask = PhysicsCategory.Wall.rawValue
        physicsBody.categoryBitMask = PhysicsCategory.Food.rawValue
        physicsBody.contactTestBitMask = PhysicsCategory.Snake.rawValue | PhysicsCategory.Wall.rawValue
        physicsBody.fieldBitMask = PhysicsCategory.None.rawValue
        physicsBody.affectedByGravity = false
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.restitution = 0.4
        physicsBody.friction = 0.1
        
        self.physicsBody = physicsBody
        
        let flameEmitterNode = SKEmitterNode(fileNamed: "FoodParticle2.sks")
        flameEmitterNode!.zPosition = -1
        self.insertChild(flameEmitterNode!, atIndex: 0)
        
        let baseNode = SKSpriteNode(texture: nil, color: self.color, size: size)
        self.addChild(baseNode)
        
        let cropNode = SKCropNode()
        cropNode.maskNode = SKSpriteNode(color: UIColor.whiteColor(), size: size)
        self.addChild(cropNode)
        
        let emitterNode = SKEmitterNode(fileNamed: "FoodParticle.sks")
        cropNode.addChild(emitterNode!)
        
        if size.width > 25 {
            flameEmitterNode!.setScale(2.0)
            emitterNode!.setScale(2.0)
        }
        
        let fieldNode = SKFieldNode.vortexField()
        fieldNode.strength = 0.0003
        fieldNode.falloff = 4
        fieldNode.categoryBitMask = FieldCategory.Food.rawValue
        fieldNode.physicsBody = self.physicsBody!.copy() as? SKPhysicsBody
        self.addChild(fieldNode)
        
        
    }
    
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func destroy() {
        
        let fadeOutAction = SKAction.fadeOutWithDuration(1.0)
        
        self.runAction(fadeOutAction, completion: { [unowned self] in
            
            self.removeFromParent()
            
        })
        
    }
    
    //MARK: Physics Scaling
    var physicsScalingFactor : CGFloat {
        get { return ClassVariables.physicsScalingFactor }
        set { ClassVariables.physicsScalingFactor = newValue }
    }
    
}
