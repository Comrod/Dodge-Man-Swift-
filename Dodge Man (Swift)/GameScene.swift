//
//  GameScene.swift
//  Dodge Man (Swift)
//
//  Created by Cormac Chester on 12/30/14.
//  Copyright (c) 2014 Extreme Images. All rights reserved.
//

import SpriteKit



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playerCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2
    let platformCategory: UInt32 = 0x1 << 3
    
    //Initialize variables outside didMoveToView
    var ground = SKSpriteNode()
    var playerSprite = SKSpriteNode()
    var starterPlatform = SKSpriteNode()
    var scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    var pauseButton = SKSpriteNode()
    var pauseLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    var resetLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    var platform = SKSpriteNode()
    var platforms:SKNode = SKNode.node()
    var score = 0
    var jumpCounter = 0
    var platformSpeed = 4.0
    var scoreString = ""
    var posX:CGFloat = 50.0
    var posY:CGFloat = 250.0
    var currentYMove:CGFloat = 0
    var currentXMove:CGFloat = 0
    var lastSpawnTimeInterval: NSTimeInterval = 0.0
    var lastUpdateTimeInterval: NSTimeInterval = 0.0
    var lastIncreaseDiffTimeInterval: NSTimeInterval = 0.0
    var lastUpdateDiffTimeInterval: NSTimeInterval = 0.0
    var startTime = NSDate()
    var isTouching = false
    
    
    override func didMoveToView(view: SKView) {

        //Add category constants for sprite collisions
        
        //Setup data storage
        
        //Sets gravity
        self.physicsWorld.gravity = CGVectorMake(0, -4.0)
        self.physicsWorld.contactDelegate = self
        
        //Sets background
        self.backgroundColor = SKColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0)
        
        //Sets ground
        ground = SKSpriteNode(imageNamed: "ground")
        ground.position = CGPointMake(CGRectGetMidX(self.frame), 34.0)
        ground.xScale = 1.0
        ground.yScale = 1.0
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = playerCategory
        ground.physicsBody?.collisionBitMask = 0
        ground.physicsBody?.friction = 0.0
        ground.name = "ground"
        
        //Player
        playerSprite = SKSpriteNode(imageNamed: "character")
        playerSprite.position = CGPointMake(posX, posY)
        
        //Set Player Physics
        playerSprite.physicsBody = SKPhysicsBody(rectangleOfSize: playerSprite.size)
        playerSprite.physicsBody?.dynamic = true
        playerSprite.physicsBody?.categoryBitMask = playerCategory
        //contactTestBitMask is not necessary
        playerSprite.physicsBody?.collisionBitMask = platformCategory|groundCategory
        playerSprite.physicsBody?.usesPreciseCollisionDetection = true
        playerSprite.physicsBody?.linearDamping = 0.3
        playerSprite.physicsBody?.allowsRotation = false
        playerSprite.physicsBody?.affectedByGravity = true
        
        //Starter Platform
        starterPlatform = SKSpriteNode(imageNamed: "platform")
        starterPlatform.xScale = 0.35
        starterPlatform.yScale = 0.35
        starterPlatform.position = CGPointMake(starterPlatform.size.width/2, self.frame.size.height - (self.frame.size.height/2))
        starterPlatform.physicsBody = SKPhysicsBody(rectangleOfSize: starterPlatform.size)
        starterPlatform.physicsBody?.dynamic = false
        starterPlatform.physicsBody?.categoryBitMask = platformCategory
        starterPlatform.physicsBody?.contactTestBitMask = playerCategory
        starterPlatform.physicsBody?.collisionBitMask = 0
        starterPlatform.physicsBody?.affectedByGravity = false
        starterPlatform.physicsBody?.usesPreciseCollisionDetection = false
        starterPlatform.physicsBody?.friction = 0.2
        
        //Score Label
        scoreLabel.text = "0"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.position = CGPointMake(50, 260)
        
        //Pause Button
        pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height-35)
        pauseButton.name = "pauseButton"
        
        //Pause Label
        pauseLabel.text = "Game Paused"
        pauseLabel.fontSize = 40
        pauseLabel.fontColor = SKColor.blackColor()
        pauseLabel.position = CGPointMake(self.size.width/2, self.size.height/2)
        
        //Reset Label
        resetLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        resetLabel.text = "Restart Game"
        resetLabel.fontSize = 40
        resetLabel.fontColor = SKColor.blackColor()
        resetLabel.position = CGPointMake(self.size.width/2, self.size.height/4);
        resetLabel.name = "resetLabel"
        
        //Platforms Node (general platforms, not specific)
        
        self.addChild(platforms)
        
        
        //Add sprites
        self.addChild(ground)
        self.addChild(starterPlatform)
        self.addChild(playerSprite)
        self.addChild(scoreLabel)
        self.addChild(pauseButton)
        
        //Remove Starter Platform delay
        //NSRunLoop.performSelector(removeStarterPlatform(), withObject:nil, afterDelay: 4.0)
    }
    
    //Spawns platforms
    func spawnPlatform()
    {
        platform = SKSpriteNode(imageNamed: "platform")
        var minY = 75 + (platform.size.height / 2)
        var maxY = self.frame.size.height - platform.size.height/2
        var rangeY = UInt32(maxY - minY)
        var actualY = CGFloat((arc4random() % rangeY) + UInt32(minY))
        
        platform.xScale = 0.35
        platform.yScale = 0.35
        
        //Initiates Platform
        platform.position = CGPointMake(self.frame.size.width + platform.size.width/2, actualY)
        platforms.addChild(platform)
        
        //Platform Physics
        platform.physicsBody = SKPhysicsBody(rectangleOfSize: platform.size)
        platform.physicsBody?.dynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        platform.physicsBody?.contactTestBitMask = playerCategory
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.usesPreciseCollisionDetection = true
        platform.physicsBody?.friction = 0.2
        
        //Create the Actions
        var actionMove = SKAction.moveTo(CGPointMake(-platform.size.width/2, actualY), duration:platformSpeed)
        var actionMoveDone = SKAction.removeFromParent()
        var platformCross = SKAction.runBlock { () -> Void in
            NSLog("Platform passed by")
            self.score++
            self.scoreString = NSString(format: String(), "%i", self.score)
            self.scoreLabel.text = self.scoreString
        }
        platform.runAction(SKAction.sequence([actionMove, platformCross, actionMoveDone]))
    }
    
    func removeStarterPlatform()
    {
        starterPlatform.removeFromParent()
    }
    
    func pauseScene()
    {
        self.paused = true
        self.addChild(pauseLabel)
        self.addChild(resetLabel)
    }
    
    func resetScene()
    {
        self.paused = false
        
        removeStarterPlatform() //Remove one if it exists
        
        playerSprite.position = CGPointMake(posX, posY);
        playerSprite.physicsBody?.velocity = CGVectorMake(0, 0);
        
        self.addChild(starterPlatform)
        //Remove after 4 seconds
        
        platforms.removeAllChildren()
        
        //Removes labels
        pauseLabel.removeFromParent()
        resetLabel.removeFromParent()
        
        score = 0
        platformSpeed = 4.0
        
    }
    
    func playerDies()
    {
        NSLog("Player died")
        playerSprite.removeFromParent()
        
        //Store final score
        
        //Change scene to endgame scene
    }
    
    func increaseDifficulty()
    {
        platformSpeed -= 0.3
        NSLog("Increasing difficulty")
    }
    
    func updateWithTimeSinceLast(timeSinceLast: CFTimeInterval)
    {
        //Platform Spawn Loop
        lastSpawnTimeInterval += timeSinceLast;
        if (lastSpawnTimeInterval > 1.5) {
            self.lastSpawnTimeInterval = 0;
            spawnPlatform()
        }
        
        //Increase difficulty with time
        lastIncreaseDiffTimeInterval += timeSinceLast;
        if (lastIncreaseDiffTimeInterval > 30)
        {
            self.lastIncreaseDiffTimeInterval = 0;
            increaseDifficulty()
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        /* Called before each frame is rendered */
        // Handle time delta.
        var timeSinceLast:CFTimeInterval = currentTime - self.lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime;
        if (timeSinceLast > 1) { //More than a second since last update
            timeSinceLast = 1.0 / 60.0;
            lastUpdateTimeInterval = currentTime;
        }
        updateWithTimeSinceLast(timeSinceLast)
        
        
        //Set current dy velocity
        //currentYMove = playerSprite.physicsBody?.velocity.dy
        //currentXMove = playerSprite.physicsBody.velocity.dx
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        isTouching = true
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            NSLog("Touch Location X: %f \n Touch Location Y: %f", location.x, location.y)
            var node = self.nodeAtPoint(location)
            //var nodeString = NSString(format: node.name!, locale: nil)
            
            if (location.x < self.frame.size.width/2)
            {
                NSLog("Tapped left")
                playerSprite.physicsBody?.velocity = CGVectorMake(-100.0, currentYMove)
            }
            else if (location.x > self.frame.size.width/2)
            {
                NSLog("Tapped right")
                playerSprite.physicsBody?.velocity = CGVectorMake(100.0, currentYMove)
            }
            
            NSLog("Player Pos: %f, %f", playerSprite.position.x, playerSprite.position.y)
            
            /*if (nodeString.isEqualToString("pauseButton"))
            {
                NSLog("Pause button pressed")
                if (!self.paused)
                {
                    pauseScene()
                }
                else if (self.paused)
                {
                    paused = false
                    pauseLabel.removeFromParent()
                    resetLabel.removeFromParent()
                }
            }
            
            if (nodeString.isEqualToString("resetLabel"))
            {
                NSLog("Reset label pressed")
                resetScene()
            }
            else if (nodeString.isEqualToString("ground"))
            {
                if (jumpCounter <= 1)
                {
                    playerSprite.physicsBody?.velocity = CGVectorMake(currentXMove, 250.0)
                    NSLog("Tapped on ground - moving player up")
                    jumpCounter++
                }
            }*/
            
        }//End of for loop
    
        startTime = NSDate.date()
        
    }//End of touchesBegan
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        isTouching = false
        
        super.touchesEnded(touches, withEvent: event)
        /* Called when a touch ends */
        
        var elapsedTime = startTime.timeIntervalSinceNow
        var elapsedTimeString = NSString(format: "Elapsed time: %f", elapsedTime)
        NSLog("%@", elapsedTimeString)
        
        NSLog("Touch ended")
    }
    
    //Collision Code
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Player collides with platform
        if ((firstBody.categoryBitMask & playerCategory) != 0 && (secondBody.categoryBitMask & platformCategory) != 0)
        {
            //Resets jump counter
            jumpCounter = 0;
            NSLog("Player and platform collided")
        }
        
        //Player collides with ground
        if ((firstBody.categoryBitMask & playerCategory) != 0 && (secondBody.categoryBitMask & groundCategory) != 0)
        {
            //playerDies()
            NSLog("Player is killed")
        }
    }
    
}
