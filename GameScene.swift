//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Patrick Lau on 2016-09-10.
//  Copyright (c) 2016 PLauDev. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // PLauDev level of difficulty measured as gap height in terms of multiple of bird height
    let difficulty: Int = 1
    let difficultyMax: Int = 10
    let difficultyMin: Int = 1
    let gapMultipleMax: CGFloat = 6.0
    let gapMultipleMin: CGFloat = 1.5
    
    let pipeInterval: NSTimeInterval = 3.0
    
    // PLauDev everything is a node - anything with an image is a sprite node
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var ground = SKNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    // PLauDev collisions
    enum ColliderTypes: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    // PLauDev game controls
    var gameOver: Bool = false
    var score = 0
    var scoreLabel = SKLabelNode()
    
    func makePipes() {
        
        let gapMultiple = gapMultipleMax - CGFloat(difficulty) * (gapMultipleMax - gapMultipleMin) / CGFloat(difficultyMax - difficultyMin)
        let gapHeight = gapMultiple * bird.size.height
        let offsetRange = self.frame.height / 2
        let pipePosOffsetY: CGFloat = CGFloat(arc4random() % UInt32(offsetRange)) - offsetRange/2
        
        // PLauDev pipe actions
        let movePipes = SKAction.moveByX(-self.frame.width * 2, y: 0, duration: NSTimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveThenRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        // PLauDev set up pipe1
        let pipeTexture1 = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipeTexture1)
        let pipePosHomeY1: CGFloat = self.frame.height/2 + pipeTexture1.size().height/2 + gapHeight/2 + pipePosOffsetY
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: pipePosHomeY1)
        pipe1.runAction(moveThenRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture1.size())
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody!.categoryBitMask = ColliderTypes.Object.rawValue // PLauDev collision
        pipe1.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue    // PLauDev collidable items
        pipe1.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue    // PLauDev pass thru allowed?
        
        // PLauDev set up pipe2
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        let pipePosHomeY2: CGFloat = self.frame.height/2 - pipeTexture2.size().height/2 - gapHeight/2 + pipePosOffsetY
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: pipePosHomeY2)
        pipe2.runAction(moveThenRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture1.size())
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody!.categoryBitMask = ColliderTypes.Object.rawValue // PLauDev collision
        pipe2.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue    // PLauDev collidable items
        pipe2.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue    // PLauDev pass thru allowed?
        
        // PLauDev each instance of SKNodes can only be added once unlike SKSpriteNode http://stackoverflow.com/a/28407033/1827488
        let gap = SKNode()
        
        // PLauDev set up gap
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.width, y: CGRectGetMidY(self.frame) + pipePosOffsetY)
        gap.runAction(moveThenRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody!.dynamic = false
        gap.physicsBody!.categoryBitMask = ColliderTypes.Gap.rawValue // PLauDev collision
        gap.physicsBody!.contactTestBitMask = ColliderTypes.Bird.rawValue    // PLauDev collidable items
        gap.physicsBody!.collisionBitMask = ColliderTypes.Gap.rawValue    // PLauDev pass thru allowed?
        
        pipe1.zPosition = 20
        pipe2.zPosition = 20
        gap.zPosition = 15
        self.addChild(pipe1)
        self.addChild(pipe2)
        self.addChild(gap)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(myLabel)
        */
        
        self.physicsWorld.contactDelegate = self
        
        // PLauDev set up background - bg.position is centre of position
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let bgMove = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9.0)
        let bgReplace = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let bgMoveForever = SKAction.repeatActionForever(SKAction.sequence([bgMove, bgReplace]))
        
        // PLauDev set up flapping bird
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture1)
        let birdHeight = birdTexture1.size().height
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdHeight/2)
        bird.physicsBody!.dynamic = true    // PLauDev affected by gravity
        bird.physicsBody!.categoryBitMask = ColliderTypes.Bird.rawValue // PLauDev collision
        bird.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue    // PLauDev collidable items
        bird.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue    // PLauDev pass thru allowed?
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        //bird.setScale(2.5)
        bird.runAction(makeBirdFlap)
        
        // PLauDev set up ground - bottom left corner is (0, 0)
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody!.categoryBitMask = ColliderTypes.Object.rawValue // PLauDev collision
        ground.physicsBody!.contactTestBitMask = ColliderTypes.Object.rawValue    // PLauDev collidable items
        ground.physicsBody!.collisionBitMask = ColliderTypes.Object.rawValue    // PLauDev pass thru allowed?
        
        // PLauDev score display
        scoreLabel.fontName = "Bradley Hand"
        scoreLabel.fontSize = 50
        let marginTop: CGFloat = 10
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height - scoreLabel.fontSize - marginTop)
        
        // PLauDev display order is supposed to be determined by the order children are added but does not work all the time & it is better to set zPosition explicitly http://stackoverflow.com/a/32532415/1827488 & http://stackoverflow.com/a/31564783/1827488
        ground.zPosition = -10
        bird.zPosition = 10
        scoreLabel.zPosition = 30
        
        // PLauDev adding children in intended order of drawing
        self.addChild(ground)
        for i in 0...2 {
            // PLauDev loop background offset by width
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i), y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            bg.runAction(bgMoveForever)
            bg.zPosition = CGFloat(i)
            self.addChild(bg)
        }
        self.addChild(bird)
        self.addChild(scoreLabel)
        
        // PLauDev set up rolling pipes
        _ = NSTimer.scheduledTimerWithTimeInterval(pipeInterval, target: self, selector: #selector(makePipes), userInfo: nil, repeats: true)
        
        // PLauDev resolved error: 2016-09-10 22:54:06.850 Flappy Bird[3575:1827296] <SKMetalLayer: 0x15c595c80>: calling -display has no effect http://stackoverflow.com/a/33027292/1827488 & harmelss? https://forums.developer.apple.com/thread/21386

    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if gameOver { return }
        
        if contact.bodyA.categoryBitMask == ColliderTypes.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderTypes.Gap.rawValue {
            score += 1
            print("contact -> score=\(score)")
            scoreLabel.text = "\(score)"
        } else {
            print("contact -> game over!")
            gameOver = true
            self.speed = 0
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        /*
        for touch in touches {
            let location = touch.locationInNode(self)
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            sprite.runAction(SKAction.repeatActionForever(action))
            self.addChild(sprite)
        }
        */
        
        if gameOver == false {
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 50))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
