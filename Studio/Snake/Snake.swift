//
//  Snake.swift
//  Snake
//
//  Created by Alexander Pagliaro on 11/14/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import Foundation
import SpriteKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum Direction {
    case none
    case up
    case down
    case left
    case right
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
        headUnit.physicsBody?.contactTestBitMask |= PhysicsCategory.wall.rawValue
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
    
    func move(_ direction: Direction, velocity: CGFloat) {
        
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
        currentUnit?.update()
        while (currentUnit?.nextUnit != nil) {
            
            currentUnit?.enforce(distanceBetweenUnits)
            
            let nextUnit = currentUnit?.nextUnit!
            nextUnit?.update()
            
            currentUnit = nextUnit
            
        }
        
    }
    
    func destroy(_ completion: (Void) -> Void) {
        
        let unit = self.headUnit
        unit?.destroy(completion)
        
    }
    
}

class SnakeUnit: SKSpriteNode {
    
    var nextUnit : SnakeUnit?
    var changePropagators : [ChangePropagator] = []
    
    fileprivate struct ClassVariables {
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
            return Direction.right
        } else if (physicsBody?.velocity.dx < 0) {
            return Direction.left
        } else if (physicsBody?.velocity.dy > 0) {
            return Direction.up
        } else if (physicsBody?.velocity.dy < 0) {
            return Direction.down
        }
        
        return Direction.none
        
    }
    
    init(rectOfSize size: CGSize) {
        
        self.init()
        
        //let rect = CGRect(origin: CGPointZero, size: size)
        //self.path = CGPathCreateWithRect(rect, nil)
        self.size = size
        self.color = UIColor(white: 0.7, alpha: 1.0)
        
        let physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody.mass = 1.0
        physicsBody.allowsRotation = false
        physicsBody.collisionBitMask = PhysicsCategory.none.rawValue
        physicsBody.categoryBitMask = PhysicsCategory.snake.rawValue
        physicsBody.contactTestBitMask = PhysicsCategory.snake.rawValue
        physicsBody.fieldBitMask = FieldCategory.none.rawValue
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
    
    func move(_ direction: Direction, velocity: CGFloat) {
        
        // Prevent moving in reverse
        if (direction == Direction.left || direction == Direction.right) {
            if (self.direction == Direction.left || self.direction == Direction.right) {
                return
            }
        }
        
        if (direction == Direction.up || direction == Direction.down) {
            if (self.direction == Direction.up || self.direction == Direction.down) {
                return
            }
        }
        
        let multiplier = CGFloat(1.0)
        
        switch (direction) {
            
        case .up :
            self.physicsBody!.velocity = CGVector(dx: 0.0, dy: velocity * multiplier)
        
        case .down :
            self.physicsBody!.velocity = CGVector(dx: 0.0, dy: -velocity * multiplier)
            
        case .left :
            self.physicsBody!.velocity = CGVector(dx: -velocity * multiplier, dy: 0.0)
            
        case .right :
            self.physicsBody!.velocity = CGVector(dx: velocity * multiplier, dy: 0.0)
            
        case .none :
            break
            
        }
        
        // Create a change propagator with current position, add it to nextUnits changePropagator
        if (nextUnit != nil) {
            
            // If nextUnit has a velocity, create a change propagator
            if (nextUnit!.direction != Direction.none) {
                nextUnit!.changePropagators.append(ChangePropagator(location: self.position, direction: direction, velocity: velocity))
            } else {
                // Move the next unit immediately
                nextUnit!.move(direction, velocity: velocity)
                nextUnit!.physicsBody?.velocity = self.physicsBody!.velocity
            }
            
            
        }
        
    }
    
    func enforce(_ distanceBetweenUnits: CGFloat) {
        
        // Only enforce if units are travelling same direction
        if (direction == nextUnit?.direction) {
            
            nextUnit?.position = positionForNextUnit(distanceBetweenUnits)
            nextUnit?.physicsBody?.velocity = physicsBody!.velocity
            
        }
        
    }
    
    func positionForNextUnit(_ distanceBetweenUnits: CGFloat) -> CGPoint {
        
        switch (direction) {
        case .down :
            return CGPoint(x: self.position.x, y: self.position.y + nextUnit!.frame.size.height + distanceBetweenUnits)
        case .right :
            return CGPoint(x: self.position.x - nextUnit!.frame.size.width - distanceBetweenUnits, y: self.position.y)
        case .left :
            return CGPoint(x: self.position.x + nextUnit!.frame.size.width + distanceBetweenUnits, y: self.position.y)
        default :
            return CGPoint(x: self.position.x, y: self.position.y - nextUnit!.frame.size.height - distanceBetweenUnits)
        }
        
    }
    
    func update() {
        
        let changePropagator = self.changePropagators.first
        
        func runChangePropagator(_ changePropagator: ChangePropagator) {
            
            self.position = changePropagator.location
            self.move(changePropagator.direction, velocity: changePropagator.velocity)
            self.changePropagators.remove(at: 0)
            
        }
        
        if (changePropagator != nil) {
            
            switch (direction) {
            case .up :
                if (self.position.y >= changePropagator!.location.y) {
                    runChangePropagator(changePropagator!)
                }
                
            case .down :
                if (self.position.y <= changePropagator!.location.y) {
                    runChangePropagator(changePropagator!)
                }
                
            case .right :
                if (self.position.x >= changePropagator!.location.x) {
                    runChangePropagator(changePropagator!)
                }
                
            case .left :
                if (self.position.x <= changePropagator!.location.x) {
                    runChangePropagator(changePropagator!)
                }
                
            default :
                return
                
            }
            
        }
        
    }
    
    func destroy(_ completion: () -> Void) {
        
        // Do stuff to destroy
        //self.physicsBody?.affectedByGravity = true
        self.physicsBody?.collisionBitMask |= PhysicsCategory.snake.rawValue | PhysicsCategory.wall.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.none.rawValue
        self.physicsBody?.allowsRotation = true
        //self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // Apply random impulse vector
        //self.physicsBody?.applyImpulse(CGVector(dx: 1.0, dy: 1.0))
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 5.0)
        self.run(fadeOutAction, completion: { () -> Void in
            self.removeFromParent()
        })
        
        if let nextUnit = self.nextUnit {
            nextUnit.destroy(completion)
        } else {
            completion()
        }
        
    }
    
}
