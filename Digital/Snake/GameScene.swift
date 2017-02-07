//
//  GameScene.swift
//  Snake
//
//  Created by Alexander Pagliaro on 11/13/14.
//  Copyright (c) 2014 Limit Point LLC. All rights reserved.
//

import SpriteKit
import GameKit

protocol PhysicsScaling {
    var physicsScalingFactor : CGFloat { get set }
}

enum PhysicsCategory : UInt32 {
    case none   = 0
    case all    = 0xFFFFFFFF
    case snake = 0b0010
    case food = 0b0100
    case other = 0b1000
    case coin = 0b1010
    case block = 0b1100
    case wall = 0b11101
}

enum FieldCategory : UInt32 {
    case none   = 0
    case all    = 0xFFFFFFFF
    case snake = 0b001
    case food = 0b010
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var snake : Snake = Snake(unitWidth: 14) // iPhone 6 width = 375
    var food : Food?
    
    var leftWall : Wall!
    var rightWall : Wall!
    var topWall : Wall!
    var bottomWall : Wall!
    
    var titleFood : Food!
    var snakeStartPoint : CGPoint = CGPoint.zero
    var foodStartPoint : CGPoint = CGPoint.zero
    var scoreBoard : ScoreBoard = ScoreBoard()
    let titleNode = SKNode()
    let cloudParticleEmitter = SKEmitterNode(fileNamed: "Cloud.sks")
    
    // Sizes dependent on device size
    var foodUnitSize = CGFloat(12)
    var snakeUnitSize = CGFloat(14)
    var titleFontSize = CGFloat(32)
    var labelTextFontSize = CGFloat(18)
    
    // Tutorial Sprites
    let tutorialNode = SKNode()
    
    // Gameover Sprites
    let gameOverLabel = SKLabelNode(fontNamed: "Fipps-Regular")
    let gameOverReason = SKLabelNode(fontNamed: "04b03")
    let highScoreParticleEmitter = SKEmitterNode(fileNamed: "Hiscore.sks")
    let newHighScoreLabel = SKLabelNode(fontNamed: "Fipps-Regular")
    let tapToContinueLabel = SKLabelNode(fontNamed: "04b03")
    let tauntLabel = SKLabelNode(fontNamed: "04b03")
    
    var destroyedFood : [Food] = []
    
    // Audio
    var musicPlayer : GameMusicPlayer = GameMusicPlayer()
    
    // Gesture recognizers
    var panGestureRecognizer = UIPanGestureRecognizer()
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        setupDeviceDependentVariables()
        setupWorld()
        
        // Set up gestureRecognizers
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameScene.panGestureRecognized(_:)))
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameScene.tapGestureRecognized(_:)))
        
        resetGame()
        
    }
    
    func setupDeviceDependentVariables() {
        
        print(self.frame.size)
        
        let screenWidth = self.frame.size.width
        
        //iPad Size
        if screenWidth >= 768.0 {
            snakeUnitSize = CGFloat(29.0)
            foodUnitSize = CGFloat(26.0)
            self.physicsWorld.speed = 2.19
        }
        
        //iPhone 6 Plus size
        else if screenWidth >= 414.0 {
            snakeUnitSize = CGFloat(17.0)
            foodUnitSize = CGFloat(14.0)
            self.physicsWorld.speed = 1.18
        }
        
    }
    
    func setupWorld() {
        
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        // Set up title + tutorials
        let titleLabel : SKLabelNode = SKLabelNode(fontNamed: "Fipps-Regular")
        titleLabel.fontColor = UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0)
        titleLabel.text = "Snake"
        
        //titleLabel.position = CGPoint(x: self.frame.size.width/2.0, y: 3*self.frame.size.height/4.0)
        let blinkOutAction = SKAction.fadeOut(withDuration: 0.1)
        let blinkInAction = SKAction.fadeIn(withDuration: 0.1)
        let blinkSequence = SKAction.sequence([SKAction.wait(forDuration: 0.7), blinkOutAction, SKAction.wait(forDuration: 0.3), blinkInAction])
        let blinkAction = SKAction.repeatForever(blinkSequence)
        titleLabel.run(blinkAction)
        
        titleNode.addChild(titleLabel)
        titleNode.position = CGPoint(x: self.frame.size.width/2.0, y: 3*self.frame.size.height/4.0)
        self.addChild(titleNode)
        
        (snakeStartPoint, foodStartPoint) = setupTutorialSprites()
        self.addChild(tutorialNode)
        
        cloudParticleEmitter!.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        cloudParticleEmitter!.fieldBitMask = FieldCategory.snake.rawValue | FieldCategory.food.rawValue
        cloudParticleEmitter!.particlePositionRange = CGVector(dx: self.frame.size.width, dy: self.frame.size.height)
        cloudParticleEmitter!.zPosition = -1
        self.addChild(cloudParticleEmitter!)
        
        // Add walls
        leftWall = Wall(size: CGSize(width: 2, height: self.frame.size.height), inverted: false)
        leftWall.position = CGPoint(x: 0, y: frame.size.height/2.0)
        self.addChild(leftWall)
        
        rightWall = Wall(size: CGSize(width: 2, height: self.frame.size.height), inverted: true)
        rightWall.position = CGPoint(x: frame.size.width, y: frame.size.height/2.0)
        self.addChild(rightWall)
        
        topWall = Wall(size: CGSize(width: self.frame.size.width, height: 2.0), inverted: true)
        topWall.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height)
        self.addChild(topWall)
        
        bottomWall = Wall(size: CGSize(width: self.frame.size.width, height: 2.0), inverted: false)
        bottomWall.position = CGPoint(x: frame.size.width/2.0, y: 0)
        self.addChild(bottomWall)
        
        let rect = scoreBoard.calculateAccumulatedFrame()
        scoreBoard.position = CGPoint(x: rect.size.width/2.0+10.0, y: rect.size.height/2.0)
        self.addChild(scoreBoard)
        
        setUpGameOverSprites()
        
    }
    
    func setupTutorialSprites() -> (snakePoint : CGPoint, foodPoint : CGPoint) {
        
        tutorialNode.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0 - 30)
        
        let handSprite = SKSpriteNode(imageNamed: "hand.png")
        let handText = SKLabelNode(fontNamed: "04b03")
        
        handSprite.size = CGSize(width: 72, height: 72)
        handSprite.alpha = 0.0
        let fadeInAction = SKAction.fadeIn(withDuration: 0.1)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
        let moveRightStartAction = SKAction.move(to: CGPoint(x: -50, y: 0.0), duration: 0.0)
        let moveRightEndAction = SKAction.move(to: CGPoint(x: 50, y: 0.0), duration: 1.0)
        let moveRightAction = SKAction.sequence([moveRightStartAction, fadeInAction, moveRightEndAction, fadeOutAction])
        moveRightAction.timingMode = SKActionTimingMode.easeOut
        
        let moveDownStartAction = SKAction.move(to: CGPoint(x: 0, y: 10.0), duration: 0.0)
        let moveDownEndAction = SKAction.move(to: CGPoint(x: 0, y: -40), duration: 1.0)
        let moveDownAction = SKAction.sequence([moveDownStartAction, fadeInAction, moveDownEndAction, fadeOutAction])
        moveDownAction.timingMode = .easeOut
        
        let moveLeftStartAction = SKAction.move(to: CGPoint(x: 50, y: 0.0), duration: 0.0)
        let moveLeftEndAction = SKAction.move(to: CGPoint(x: -50, y: 0.0), duration: 1.0)
        let moveLeftAction = SKAction.sequence([moveLeftStartAction, fadeInAction, moveLeftEndAction, fadeOutAction])
        moveLeftAction.timingMode = .easeOut
        
        let moveUpStartAction = SKAction.move(to: CGPoint(x: 0, y: -40), duration: 0.0)
        let moveUpEndAction = SKAction.move(to: CGPoint(x: 0, y: 10), duration: 1.0)
        let moveUpAction = SKAction.sequence([moveUpStartAction, fadeInAction, moveUpEndAction, fadeOutAction])
        moveUpAction.timingMode = .easeOut
        
        let pauseAction = SKAction.wait(forDuration: 0.2)
        
        let handSequence = SKAction.sequence([moveRightAction, pauseAction, moveDownAction, pauseAction, moveLeftAction, pauseAction, moveUpAction, pauseAction])
        
        let repeatingAction = SKAction.repeatForever(handSequence)
        handSprite.run(repeatingAction)
        tutorialNode.addChild(handSprite)
        
        handText.text = "swipe anywhere to move"
        handText.fontColor = UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0)
        handText.fontSize = labelTextFontSize
        handText.position = CGPoint(x: 0, y: 70)
        tutorialNode.addChild(handText)
        
        let arrowSprite = SKSpriteNode(imageNamed: "arrow.png")
        arrowSprite.setScale(0.5)
        titleFood = Food(rectOfSize: CGSize(width: foodUnitSize, height: foodUnitSize))
        
        arrowSprite.position = CGPoint(x: 0, y: handText.position.y + labelTextFontSize*2 + (foodUnitSize > 16 ? foodUnitSize : 0))
        tutorialNode.addChild(arrowSprite)
        
        let foodPosition = CGPoint(x: arrowSprite.size.width, y: arrowSprite.position.y)
        let snakePosition = CGPoint(x: -arrowSprite.size.width, y: arrowSprite.position.y)
        
        return (snakePosition, foodPosition)
        
    }
    
    func setUpGameOverSprites() {
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontColor = UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0)
        
        gameOverReason.fontColor = UIColor.black
        gameOverReason.fontSize = 18
        
        newHighScoreLabel.text = "New High Score!"
        newHighScoreLabel.fontSize = 16
        newHighScoreLabel.fontColor = UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0)
        newHighScoreLabel.addChild(highScoreParticleEmitter!)
        
        tapToContinueLabel.text = "Tap anywhere to continue"
        tapToContinueLabel.fontColor = UIColor.black
        tapToContinueLabel.fontSize = 20
        
        tauntLabel.fontColor = UIColor(red: 0.2, green: 0.1, blue: 0.9, alpha: 1.0)
        tauntLabel.fontSize = 24
        
    }
    
    func resetGame() {
        
        self.view?.removeGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: GameViewControllerNotifications.didEnd), object: nil)
        
        // Clean up
        for food in destroyedFood {
            food.removeFromParent()
        }
        food?.removeFromParent()
        snake.removeFromParent()
        gameOverLabel.removeFromParent()
        gameOverReason.removeFromParent()
        tapToContinueLabel.removeFromParent()
        newHighScoreLabel.removeFromParent()
        tauntLabel.removeFromParent()
        
        // Show title
        self.titleNode.alpha = 1.0
        self.tutorialNode.alpha = 1.0
        
        // Create snake
        snake = Snake(unitWidth: snakeUnitSize)
        snake.position = tutorialNode.convert(snakeStartPoint, to: self)
        self.addChild(snake)
        
        // Create initial food
        titleFood = Food(rectOfSize: CGSize(width: foodUnitSize, height: foodUnitSize))
        titleFood.position = tutorialNode.convert(foodStartPoint, to: self)
        self.addChild(titleFood)
        
        // Reset score
        scoreBoard.position = CGPoint(x: 10, y: 10)
        scoreBoard.displayHiScore(GameScoreManager.highscore())
        
        // Reset walls, just in case
        leftWall.position = CGPoint(x: 0, y: frame.size.height/2.0)
        rightWall.position = CGPoint(x: frame.size.width, y: frame.size.height/2.0)
        topWall.position = CGPoint(x: frame.size.width/2.0, y: frame.size.height)
        bottomWall.position = CGPoint(x: frame.size.width/2.0, y: 0)
        
        self.view?.addGestureRecognizer(panGestureRecognizer)
        
        destroyedFood = []
        
        musicPlayer.playTitleMusic()
        
    }
    
    func startGame() {
        
        if (food == nil) {
            
            titleNode.alpha = 0.0
            tutorialNode.alpha = 0.0
            
            scoreBoard.reset()
            
            musicPlayer.playStartFX()
            
            //5% of the time, start the other song
            let random = arc4random() % 100
            if random < 20 {
                musicPlayer.prepareLevel2()
            }            
            musicPlayer.playNextSong()
            
            self.food = titleFood//generateFoodInRect(CGRectInset(self.frame, foodUnitSize*2, foodUnitSize*2))!
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: GameViewControllerNotifications.didStart), object: nil)
        }
        
    }
    
    func gameOver(_ gameOverTip : String) {
        
        print("game over")
        
        self.view?.removeGestureRecognizer(panGestureRecognizer)
        self.view?.addGestureRecognizer(tapGestureRecognizer)
        
        if let food = self.food {
            food.removeFromParent()
            self.food = nil
        }
        
        snake.destroy() {
            
        }
        
        gameOverLabel.position = CGPoint(x: self.frame.size.width/2.0, y: 3*self.frame.size.height/4.0)
        gameOverLabel.isPaused = false
        gameOverLabel.alpha = 0.0
        self.addChild(gameOverLabel)
        
        gameOverReason.position = CGPoint(x: self.frame.size.width/2.0, y: gameOverLabel.position.y - 45)
        gameOverReason.text = gameOverTip
        gameOverReason.alpha = 0.0
        self.addChild(gameOverReason)
        
        tauntLabel.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        tauntLabel.text = tauntForScore(scoreBoard.score)
        tauntLabel.alpha = 0.0
        self.addChild(tauntLabel)
        
        tapToContinueLabel.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/4.0)
        tapToContinueLabel.alpha = 0.0
        self.addChild(tapToContinueLabel)
        
        // Fade in and scale up
        let fadeInAction = SKAction.fadeIn(withDuration: 3.0)
        let scaleAction = SKAction.scale(to: 1.1, duration: 3.0)
        
        let groupAction = SKAction.group([fadeInAction, scaleAction])
        
        // Scale down
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.3)
        
        let sequenceAction = SKAction.sequence([groupAction, scaleDownAction])
        
        gameOverLabel.run(sequenceAction)
        gameOverReason.run(fadeInAction)
        tapToContinueLabel.run(fadeInAction)
        tauntLabel.run(fadeInAction)
        
        musicPlayer.playEndFX()
        musicPlayer.playGameOverMusic()
        
        // Check if we have a high score
        if GameScoreManager.reportScore(scoreBoard.score) {
            
            newHighScoreLabel.position = CGPoint(x: self.frame.size.width/2.0, y: tauntLabel.position.y-50)
            newHighScoreLabel.alpha = 0.0
            self.addChild(newHighScoreLabel)
            newHighScoreLabel.run(fadeInAction)
            
        }
        
    }
    
    func updateGameForScore(_ score: Int) {
        
        if (score > GameScoreManager.highscore()) {
            musicPlayer.prepareLevel2()
        }
        
        // Play next song after 30
        if (score > 20) {
            
            musicPlayer.prepareLevel2()
            
        }
        
    }
    
    func tauntForScore(_ score: Int) -> String {
        
        let randomValue = arc4random() % 100
        
        switch (score) {
        case 0...10:
            if randomValue > 66 {
                return "That was weak."
            } else if randomValue > 33 {
                return "Pathetic."
            } else {
                return "You're better than this."
            }
        case 11...30:
            if randomValue > 50 {
                return "That all you got?"
            } else {
                return "Try a little harder."
            }
        case 31...50:
            if randomValue > 50 {
                return "Nice work!"
            } else {
                return "Satisfactory."
            }
        case 51...70:
            if randomValue > 50 {
                return "Wow, great job!"
            } else {
                return "Excellent."
            }
        case 71...100:
            if randomValue > 50 {
                return "Amazing!"
            } else {
                return "Truly stunning."
            }
        default:
            if randomValue > 50 {
                return "You're incredible!"
            } else {
                return "Wowzers."
            }
        }
        
    }
    
    //MARK: - Food -
    
    func generateFoodInRect(_ rect : CGRect) -> Food? {
        
        let point = searchForAvailableSpace(rect)
        if (point != nil) {
            
            let food = Food(rectOfSize: CGSize(width: foodUnitSize, height: foodUnitSize))
            food.position = point!
            
            print("did generate food at point ", food)
            
            food.alpha = 0.0
            let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
            
            self.addChild(food)
            food.run(fadeInAction)
            
            return food
            
        }
        
        return nil
        
    }
    
    func searchForAvailableSpace(_ rect : CGRect) -> CGPoint? {
        
        let searchRectPadding = CGFloat(2.0)
        
        let startPoint : CGPoint = randomPointInRect(rect);
        
        var foundSpace = false
        var searchedAllSpaces = false
        var point = startPoint
        var searchDistance = CGFloat(0)
        let searchWidth = CGFloat(5)
        
        while (foundSpace == false && searchedAllSpaces == false) {
            
            let searchRect = CGRect(origin: point, size: CGSize(width: CGFloat(foodUnitSize)+searchRectPadding, height: CGFloat(foodUnitSize)+searchRectPadding))
            
            var bodyFound = false
            
            self.physicsWorld.enumerateBodies(in: searchRect, using: { (physicsBody, _) -> Void in
                
                if (physicsBody.node != self) {
                    
                    bodyFound = true
                    
                }
                
            })
            
            if (bodyFound) {
                
                // Move point right
                point.x += searchWidth
                
                // If search rect goes beyond rect width
                if (point.x + searchWidth > rect.maxX) {
                    
                    point.x = rect.minX
                    point.y += searchWidth
                    searchDistance += searchWidth
                    
                }
                
                // If search rect goes beyond rect height
                if (point.y + searchWidth > rect.maxY) {
                    
                    point.y = rect.minY
                    
                }
                
                // If searchDistance is greater than rect height, we're done
                if (searchDistance >= rect.height) {
                    
                    searchedAllSpaces = true
                    
                }
                
            } else {
                
                foundSpace = true
                
            }
            
        }
            
        if (foundSpace == true) {
            
            return CGPoint(x: point.x+(searchRectPadding/2.0), y: point.y+(searchRectPadding/2.0))
            
        }
        
        return nil
        
    }
    
    func randomPointInRect(_ rect : CGRect) -> CGPoint {
        
        let maxX = UInt32(rect.maxX)
        let minX = UInt32(rect.minX)
        let maxY = UInt32(rect.maxY)
        let minY = UInt32(rect.minY)
        
        let x = Int(((arc4random() % maxX) + minX))
        let y = Int(((arc4random() % maxY) + minY))
        
        return CGPoint(x: x, y: y)
        
    }
    
    //MARK: - Gesture Recognizers -
    
    func panGestureRecognized(_ sender: UIPanGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.ended) {
            
            startGame()
            
            let snakeVelocity = snake.headUnit.physicsBody!.velocity
            
            var newVelocity : CGFloat = 100.0
            
            if (fabs(snakeVelocity.dx) > 0) {
                
                newVelocity = fabs(snakeVelocity.dx)
                
            } else if (fabs(snakeVelocity.dy) > 0) {
                
                newVelocity = fabs(snakeVelocity.dy)
                
            }
            
            let velocityInView : CGPoint = sender.velocity(in: self.view!)
            
            
            
            if (fabs(velocityInView.x) >= fabs(velocityInView.y)) {
                
                if (velocityInView.x > 0) {
                    snake.move(Direction.right, velocity: newVelocity)
                } else {
                    snake.move(Direction.left, velocity: newVelocity)
                }
                
            } else {
                
                if (velocityInView.y > 0) {
                    snake.move(Direction.down, velocity: newVelocity)
                } else {
                    snake.move((Direction.up), velocity: newVelocity)
                }
                
            }
            
        }
        
    }
    
    func tapGestureRecognized(_ sender: UITapGestureRecognizer) {
        
        //if (sender.state == UIGestureRecognizerState.Began) {
            
            // Check game state
            // Is there food?
            if self.food != nil {
                
                // Pause the game
                if let skView = self.view {
                    skView.isPaused = true
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: GameViewControllerNotifications.shouldPause), object: self)
                
            } else {
                
                // Continue game
                resetGame()
                
            }
            
        //}
        
    }
    
    func pauseMusic() {
        
        musicPlayer.pause()
        
    }
    
    func resumeMusic() {
        
        musicPlayer.resume()
        
    }
    
    /*
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.moveByX(1, y: 0, duration: 1.0);
            
            effectNode.runAction(SKAction.repeatActionForever(action))
            
            effectNode.addChild(sprite)
        }
    }
*/
    
    //MARK: - Game Loop -
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if (self.food != nil) {
            snake.updateUnits()
        }
        
    }
    
    func hasGameStarted() -> Bool {
        
        if (self.food == nil) {
            return false
        }
        
        return true
        
    }
    
    //MARK: - Collision Methods -
    
    func snakeTouchedFood(_ food: Food, contact: SKPhysicsContact) {
        
        //if (destroyedFood.contains(food)) {
          //  print("what?? we destroyed this already")
            //return
        //}
        
        //destroyedFood.append(food)
        
        food.physicsBody?.collisionBitMask = PhysicsCategory.wall.rawValue
        food.physicsBody?.contactTestBitMask = PhysicsCategory.none.rawValue
        
        let impulseVector = CGVector(dx: snake.headUnit.physicsBody!.velocity.dx, dy: snake.headUnit.physicsBody!.velocity.dy)
        
        var snakeImpulseVector = CGVector(dx: 0, dy: 0)
        let impulseMagnitude = CGFloat(5.0)
        if (impulseVector.dx > 0) {
            snakeImpulseVector = CGVector(dx: impulseMagnitude, dy: 0)
        } else if (impulseVector.dx < 0) {
            snakeImpulseVector = CGVector(dx: -impulseMagnitude, dy: 0)
        } else if (impulseVector.dy > 0) {
            snakeImpulseVector = CGVector(dx: 0, dy: impulseMagnitude)
        } else if (impulseVector.dy < 0) {
            snakeImpulseVector = CGVector(dx: 0, dy: -impulseMagnitude)
        }
        
        snake.headUnit.physicsBody?.applyImpulse(snakeImpulseVector)
        
        food.removeFromParent()
        
        let action = SKAction.run({ [unowned self] in
            
            self.musicPlayer.playFX()
            self.food = self.generateFoodInRect(self.frame.insetBy(dx: self.foodUnitSize, dy: self.foodUnitSize))
            self.snake.addUnit()
            self.scoreBoard.addToScore(1)
            self.updateGameForScore(self.scoreBoard.score)
            
        })
    
        self.run(action)
        
    }
    
    func snakeTouchedWall(_ contact: SKPhysicsContact) {
        
        gameOver("Don't touch the walls!")
        
        if let snakeUnit = contact.bodyB.node as? SnakeUnit {
            
            let velocity = snakeUnit.physicsBody!.velocity
            
            snakeUnit.physicsBody?.applyImpulse(CGVector(dx: -velocity.dx*CGFloat(scoreBoard.score+3), dy: -velocity.dy*CGFloat(scoreBoard.score+3)))
            snakeUnit.physicsBody?.applyAngularImpulse(1)
            
            //snakeUnit.nextUnit?.physicsBody?.applyImpulse(CGVector(dx: -velocity.dx*CGFloat(scoreBoard.score+3), dy: -velocity.dy*CGFloat(scoreBoard.score+3)))
            //snakeUnit.nextUnit?.physicsBody?.applyAngularImpulse(contact.collisionImpulse)
            
        }
        
        /*
        let velocity = contact.bodyB.velocity
        contact.bodyB.applyImpulse(CGVector(dx: -velocity.dx*CGFloat(scoreBoard.score+3), dy: -velocity.dy*CGFloat(scoreBoard.score+3)))
        contact.bodyB.applyAngularImpulse(contact.collisionImpulse*10000)
*/
        
    }
    
    func snakeTouchedSnake() {
    
        if self.food != nil {
         
            gameOver("Don't hit yourself!")
            
        }
        
    }
    
    func foodTouchedWall(_ contact: SKPhysicsContact) {
        
        // Reflect food off wall
        
        
    }
    
    //MARK: - SKPhysicsWorldContactDelegate -
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Snake + Wall
        if (contact.bodyA.categoryBitMask == PhysicsCategory.wall.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.snake.rawValue) {
            
            snakeTouchedWall(contact)
            
        }
        
        if (contact.bodyB.categoryBitMask == PhysicsCategory.wall.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.snake.rawValue) {
            
            snakeTouchedWall(contact)
            
        }
        
        // Snake + snake
        if (contact.bodyA.categoryBitMask == PhysicsCategory.snake.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.snake.rawValue) {
            
            if (contact.bodyA.node == snake.headUnit && contact.bodyB.node != snake.headUnit.nextUnit) {
                
                snakeTouchedSnake()
                
            }
            
            if (contact.bodyB.node == snake.headUnit && contact.bodyA.node != snake.headUnit.nextUnit) {
                
                snakeTouchedSnake()
                
            }
            
            
        }
        
        // Snake + Food
        if (contact.bodyA.categoryBitMask == PhysicsCategory.snake.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.food.rawValue) {
            
            //if (contact.bodyA.node == snake.headUnit) {
                
                if let food = contact.bodyB.node as? Food {
                
                    snakeTouchedFood(food, contact: contact)
                    
                }
                
            //}
            
        }
        
        if (contact.bodyB.categoryBitMask == PhysicsCategory.snake.rawValue && contact.bodyA.categoryBitMask == PhysicsCategory.food.rawValue) {
            
            //if (contact.bodyB.node == snake.headUnit) {
                
                if let food = contact.bodyA.node as? Food {
                    
                    snakeTouchedFood(food, contact: contact)
                    
                }
                
            //}
            
        }
        
        // Food + Wall
        if (contact.bodyA.categoryBitMask == PhysicsCategory.wall.rawValue && contact.bodyB.categoryBitMask == PhysicsCategory.food.rawValue) {
            
            
            
        }
        
    }
    
}
