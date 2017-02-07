//
//  Snake.swift
//  Snake
//
//  Created by Alexander Pagliaro on 11/14/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import Foundation
import SpriteKit

enum Direction {
    case None
    case Up
    case Down
    case Left
    case Right
}

struct ChangePropagator {
    var location : CGPoint
    var direction : Direction
    var velocity : CGFloat
}

class Snake: SKNode {
    
    var headUnit : SnakeUnit!
    var tailUnit : SnakeUnit!
    
    var distanceBetweenUnits : CGFloat {
        
        var scaleFactor : CGFloat = CGFloat(1.0)
        
        if (headUnit.size.width > 20) {
            scaleFactor = CGFloat(2.0)
        } else if (headUnit.size.width > 14) {
            scaleFactor = CGFloat(1.2)
        }
        
        let lowerBound = 2.0 * scaleFactor
        
        if let velocity = self.headUnit.physicsBody?.velocity {
            
            let magnitude = abs(velocity.dx) > 0 ? abs(velocity.dx) : abs(velocity.dy)
            
            let upperBound = 10.0 * scaleFactor
            
            let m = magnitude * 0.04 * scaleFactor
            
            if m > lowerBound && m < upperBound {
                return m
            }
            
            if m >= upperBound {
                return upperBound
            }
            
        }
        
        return lowerBound
        
    }
    
    convenience init(unitWidth: CGFloat) {
        
        self.init()
        
        // Create the head node
        headUnit = SnakeUnit(rectOfSize: CGSize(width: unitWidth, height: unitWidth))
        //headUnit.fillColor = UIColor.blackColor()
        // Allow head unit to contact food
        headUnit.physicsBody?.contactTestBitMask |= PhysicsCategory.Wall.rawValue
        headUnit.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(headUnit)
        
        //let field = SKFieldNode.electricField()
        //field.falloff = 4
        //field.strength = 0.000037
        //field.categoryBitMask = FieldCategory.Snake.rawValue
        //field.physicsBody = headUnit.physicsBody!.copy() as? SKPhysicsBody
        //headUnit.addChild(field)
        
        tailUnit = headUnit
        
    }
    
    func move(direction: Direction, velocity: CGFloat) {
        
        // Move the head unit
        headUnit.move(direction, velocity: velocity)
        
    }
    
    func addUnit() {
        
        let unit = SnakeUnit(rectOfSize: headUnit.frame.size)
        //unit.fillColor = UIColor.blueColor()
        self.addChild(unit)
        
        tailUnit.nextUnit = unit
        unit.position = tailUnit.positionForNextUnit(distanceBetweenUnits)
        unit.physicsBody?.velocity = tailUnit.physicsBody!.velocity
        
        tailUnit = unit
        
    }
    
    func updateUnits() {
        
        // Loop through units and check if any unit needs to changes velocity
        var currentUnit = headUnit
        currentUnit.update()
        while (currentUnit.nextUnit != nil) {
            
            currentUnit.enforce(distanceBetweenUnits)
            
            let nextUnit = currentUnit.nextUnit!
            nextUnit.update()
            
            currentUnit = nextUnit
            
        }
        
    }
    
    func destroy(completion: Void -> Void) {
        
        let unit = self.headUnit
        unit.destroy(completion)
        
    }
    
}

class SnakeUnit: SKSpriteNode {
    
    var nextUnit : SnakeUnit?
    var changePropagators : [ChangePropagator] = []
    
    private struct ClassVariables {
        static var physicsScalingFactor : CGFloat = CGFloat(1.0)
    }
    
    internal class var physicsScalingFactor : CGFloat {
        get { return ClassVariables.physicsScalingFactor }
        set { ClassVariables.physicsScalingFactor = newValue }
    }
    
    /*
    //MARK: Physics Scaling
    var physicsScalingFactor : CGFloat {
        get { return ClassVariables.physicsScalingFactor }
        set { ClassVariables.physicsScalingFactor = newValue }
    }
*/
    
    var direction : Direction {
        
        if (physicsBody?.velocity.dx > 0) {
            return Direction.Right
        } else if (physicsBody?.velocity.dx < 0) {
            return Direction.Left
        } else if (physicsBody?.velocity.dy > 0) {
            return Direction.Up
        } else if (physicsBody?.velocity.dy < 0) {
            return Direction.Down
        }
        
        return Direction.None
        
    }
    
    init(rectOfSize size: CGSize) {
        
        self.init()
        
        //let rect = CGRect(origin: CGPointZero, size: size)
        //self.path = CGPathCreateWithRect(rect, nil)
        self.size = size
        self.color = UIColor(white: 0.7, alpha: 1.0)
        
        let physicsBody = SKPhysicsBody(rectangleOfSize: size)
        physicsBody.mass = 1.0
        physicsBody.allowsRotation = false
        physicsBody.collisionBitMask = PhysicsCategory.None.rawValue
        physicsBody.categoryBitMask = PhysicsCategory.Snake.rawValue
        physicsBody.contactTestBitMask = PhysicsCategory.Snake.rawValue
        physicsBody.fieldBitMask = FieldCategory.None.rawValue
        physicsBody.friction = 0.0
        physicsBody.linearDamping = 0.0
        physicsBody.charge = 0.00016
        physicsBody.affectedByGravity = false
        physicsBody.restitution = 0.95
        physicsBody.usesPreciseCollisionDetection = true
        
        self.physicsBody = physicsBody
        
    }
    
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func move(direction: Direction, velocity: CGFloat) {
        
        // Prevent moving in reverse
        if (direction == Direction.Left || direction == Direction.Right) {
            if (self.direction == Direction.Left || self.direction == Direction.Right) {
                return
            }
        }
        
        if (direction == Direction.Up || direction == Direction.Down) {
            if (self.direction == Direction.Up || self.direction == Direction.Down) {
                return
            }
        }
        
        let multiplier = CGFloat(1.0)
        
        switch (direction) {
            
        case .Up :
            self.physicsBody!.velocity = CGVector(dx: 0.0, dy: velocity * multiplier)
        
        case .Down :
            self.physicsBody!.velocity = CGVector(dx: 0.0, dy: -velocity * multiplier)
            
        case .Left :
            self.physicsBody!.velocity = CGVector(dx: -velocity * multiplier, dy: 0.0)
            
        case .Right :
            self.physicsBody!.velocity = CGVector(dx: velocity * multiplier, dy: 0.0)
            
        case .None :
            break
            
        }
        
        // Create a change propagator with current position, add it to nextUnits changePropagator
        if (nextUnit != nil) {
            
            // If nextUnit has a velocity, create a change propagator
            if (nextUnit!.direction != Direction.None) {
                nextUnit!.changePropagators.append(ChangePropagator(location: self.position, direction: direction, velocity: velocity))
            } else {
                // Move the next unit immediately
                nextUnit!.move(direction, velocity: velocity)
                nextUnit!.physicsBody?.velocity = self.physicsBody!.velocity
            }
            
            
        }
        
    }
    
    func enforce(distanceBetweenUnits: CGFloat) {
        
        // Only enforce if units are travelling same direction
        if (direction == nextUnit?.direction) {
            
            nextUnit?.position = positionForNextUnit(distanceBetweenUnits)
            nextUnit?.physicsBody?.velocity = physicsBody!.velocity
            
        }
        
    }
    
    func positionForNextUnit(distanceBetweenUnits: CGFloat) -> CGPoint {
        
        switch (direction) {
        case .Down :
            return CGPoint(x: self.position.x, y: self.position.y + nextUnit!.frame.size.height + distanceBetweenUnits)
        case .Right :
            return CGPoint(x: self.position.x - nextUnit!.frame.size.width - distanceBetweenUnits, y: self.position.y)
        case .Left :
            return CGPoint(x: self.position.x + nextUnit!.frame.size.width + distanceBetweenUnits, y: self.position.y)
        default :
            return CGPoint(x: self.position.x, y: self.position.y - nextUnit!.frame.size.height - distanceBetweenUnits)
        }
        
    }
    
    func update() {
        
        let changePropagator = self.changePropagators.first
        
        func runChangePropagator(changePropagator: ChangePropagator) {
            
            self.position = changePropagator.location
            self.move(changePropagator.direction, velocity: changePropagator.velocity)
            self.changePropagators.removeAtIndex(0)
            
        }
        
        if (changePropagator != nil) {
            
            switch (direction) {
            case .Up :
                if (self.position.y >= changePropagator!.location.y) {
                    runChangePropagator(changePropagator!)
                }
                
            case .Down :
                if (self.position.y <= changePropagator!.location.y) {
                    runChangePropagator(changePropagator!)
                }
                
            case .Right :
                if (self.position.x >= changePropagator!.location.x) {
                    runChangePropagator(changePropagator!)
                }
                
            case .Left :
                if (self.position.x <= changePropagator!.location.x) {
                    runChangePropagator(changePropagator!)
                }
                
            default :
                return
                
            }
            
        }
        
    }
    
    func destroy(completion: () -> Void) {
        
        // Do stuff to destroy
        //self.physicsBody?.affectedByGravity = true
        self.physicsBody?.collisionBitMask |= PhysicsCategory.Snake.rawValue | PhysicsCategory.Wall.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.None.rawValue
        self.physicsBody?.allowsRotation = true
        //self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // Apply random impulse vector
        //self.physicsBody?.applyImpulse(CGVector(dx: 1.0, dy: 1.0))
        
        let fadeOutAction = SKAction.fadeOutWithDuration(5.0)
        self.runAction(fadeOutAction, completion: { () -> Void in
            self.removeFromParent()
        })
        
        if let nextUnit = self.nextUnit {
            nextUnit.destroy(completion)
        } else {
            completion()
        }
        
    }
    
}