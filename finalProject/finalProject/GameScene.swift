//
//  GameScene.swift
//  finalProject
//
//  Created by Corrin, Will on 5/4/16.
//  Copyright (c) 2016 Corrin, Will. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //////ENUMS////////
    //to tell whether it is us or an enemy firing.
    enum BulletType
    {
        case ShipFired
        case InvaderFired
    }
    
    //types of enemies
    enum EnemyType
    {
        case Blue
        case Red
        case Green
        
        static var name: String {
            return "invader"
        }
        
        static var size: CGSize {
            return CGSize(width: 24, height: 16)
        }
    }
    
    enum AIDirection
    {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    ///////////////////
    
    ////////CONSTANTS///////////
    
    //ending the game
    let kMinInvaderBottomHeight: Float = 32.0
    var gameEnding: Bool = false
    var viewController: GameViewController!
    
    //score
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    //player constants
    var player = SKSpriteNode(imageNamed: "playerShip")
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    //for bullets
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSize(width:4, height: 8)
    
    //for touches
    var tapQueue = [Int]()
    //for physics
    var contactQueue = [SKPhysicsContact]()
    
    //accelerometer
    let motionManager : CMMotionManager = CMMotionManager()
    
    //detecting collisions (this was hard to implement and i needed help)
    //use bitmask for collision layers
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    var invaderMovementDirection: AIDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    let timePerMove: CFTimeInterval = 0.1
    ///////////////////////////
    
    ////////METHODS//////////////
    
    override func didMoveToView(view: SKView)
    {
        //create and add background
        let background = SKSpriteNode(imageNamed: "spacebackground")
        background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        background.zPosition = -1
        addChild(background)
        
        //give bounds to the world, set collision layer
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        physicsWorld.contactDelegate = self
        
        //setup
        setupShip()
        setupInvaders()
        setupHud()
        motionManager.startAccelerometerUpdates()
    }
    
    //sets up the player ship
    func setupShip()
    {
        // 1
        player = makeShip()
        
        // 2
        player.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        addChild(player)
    }
    
    //makes the ship and returns it as a Node
    func makeShip() -> SKSpriteNode
    {
        let ship = SKSpriteNode(imageNamed: "playerShip")
        ship.name = kShipName
        ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.frame.size)
        ship.physicsBody!.dynamic = true
        ship.physicsBody!.affectedByGravity = false
        ship.physicsBody!.mass = 0.02
        ship.physicsBody!.categoryBitMask = kShipCategory
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
        return ship
    }
    
    func setupInvaders() {
        // 1
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
        
        for row in 0..<kInvaderRowCount {
            // 2
            var invaderType: EnemyType
            
            if row % 3 == 0 {
                invaderType = .Red
            } else if row % 3 == 1 {
                invaderType = .Blue
            } else {
                invaderType = .Green
            }
            
            // 3
            let invaderPositionY = CGFloat(row) * (EnemyType.size.height * 2) + baseOrigin.y
            
            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
            
            // 4
            for _ in 1..<kInvaderRowCount {
                // 5
                let invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                invader.physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)
                invader.physicsBody!.dynamic = false
                invader.physicsBody!.categoryBitMask = kInvaderCategory
                invader.physicsBody!.contactTestBitMask = 0x0
                invader.physicsBody!.collisionBitMask = 0x0
                
                addChild(invader)
                
                invaderPosition = CGPoint(
                    x: invaderPosition.x + EnemyType.size.width + kInvaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }
    
    //keeps track of touches
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first {
            if (touch.tapCount == 1) {
                tapQueue.append(1)
            }
        }
    }
    
    //contacts for physics
    func didBeginContact(contact: SKPhysicsContact) {
        contactQueue.append(contact)
    }
    
    //func for actually handling the collisions
    func handleContact(contact: SKPhysicsContact) {
        // Ensure you haven't already handled this contact and removed its nodes
        if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if nodeNames.contains(kShipName) && nodeNames.contains(kInvaderFiredBulletName) {
            // Invader bullet hit a ship
            runAction(SKAction.playSoundFileNamed("explode.wav", waitForCompletion: false))
            
            // 1
            adjustShipHealthBy(-0.334)
            
            if shipHealth <= 0.0 {
                // 2
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
            } else {
                // 3
                if let ship = self.childNodeWithName(kShipName) {
                    ship.alpha = CGFloat(shipHealth)
                    
                    if contact.bodyA.node == ship {
                        contact.bodyB.node!.removeFromParent()
                        
                    } else {
                        contact.bodyA.node!.removeFromParent()
                    }
                }
            }
            
        } else if nodeNames.contains(EnemyType.name) && nodeNames.contains(kShipFiredBulletName) {
            // Ship bullet hit an invader
            runAction(SKAction.playSoundFileNamed("explode.wav", waitForCompletion: false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            // 4
            adjustScoreBy(100)
        }
    }
    
    //////END GAME LOGIC/////////
    func isGameOver() -> Bool {
        // 1
        let invader = childNodeWithName(EnemyType.name)
        
        // 2
        var invaderTooLow = false
        
        enumerateChildNodesWithName(EnemyType.name)
            {
            node, stop in
            
            if (Float(CGRectGetMinY(node.frame)) <= self.kMinInvaderBottomHeight)   {
                invaderTooLow = true
                stop.memory = true
            }
        }
        
        // 3
        let ship = childNodeWithName(kShipName)
        
        // 4
        return invader == nil || invaderTooLow || ship == nil
    }
    
    func endGame() {
        // 1
        if !gameEnding
        {
            gameEnding = true
            motionManager.stopAccelerometerUpdates()
            removeAllChildren()
            removeAllActions()
            removeFromParent()
            
            //score stuff
            let def = NSUserDefaults()
            def.setInteger(score, forKey: "score")
            let HIscore = def.valueForKey("hiscore") as! Int
            if(score > HIscore)
            {
                def.setInteger(score, forKey: "hiscore")
            }
            def.synchronize()
            
            self.viewController.gameOver()
        }
    }
    ////////////////////////////
    
    ///ENEMIES
    func makeInvaderOfType(invaderType: EnemyType) -> SKNode
    {
        // 1
        var invaderString: String
        
        switch(invaderType)
        {
            case .Red:
                invaderString = "enemyShip"
            case .Blue:
                invaderString = "enemyShip2"
            case .Green:
                invaderString = "enemyShip3"
        }
        
        // 2
        let invader = SKSpriteNode(imageNamed: invaderString)
        invader.name = EnemyType.name
        
        return invader
    }
    
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        // 1
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        determineInvaderMovementDirection()
        
        // 2
        enumerateChildNodesWithName(EnemyType.name) {
            node, stop in
            
            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPointMake(node.position.x + 1, node.position.y)
            case .Left:
                node.position = CGPointMake(node.position.x - 1, node.position.y)
            case .DownThenLeft, .DownThenRight:
                node.position = CGPointMake(node.position.x, node.position.y - 1)
            case .None:
                break
            }
            
            // 3
            self.timeOfLastMove = currentTime
        }
    }
    
    func determineInvaderMovementDirection() {
        // 1
        var proposedMovementDirection: AIDirection = invaderMovementDirection
        
        // 2
        enumerateChildNodesWithName(EnemyType.name) {
            node, stop in
            
            switch self.invaderMovementDirection {
            case .Right:
                //3
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    
                    stop.memory = true
                }
            case .Left:
                //4
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
                
            case .DownThenLeft:
                proposedMovementDirection = .Left
                
                stop.memory = true
                
            case .DownThenRight:
                proposedMovementDirection = .Right
                
                stop.memory = true
                
            default:
                break
            }
            
        }
        
        //7
        if (proposedMovementDirection != invaderMovementDirection) {
            invaderMovementDirection = proposedMovementDirection
        }
    }
    
    ////BULLETS//////////
    
    //creates a bullet
    func makeBulletOfType(bulletType: BulletType) -> SKNode {
        var bullet: SKNode
        
        switch bulletType
        {
            //case for player firing
            case .ShipFired:
                bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
                bullet.name = kShipFiredBulletName
                bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
                bullet.physicsBody!.dynamic = true
                bullet.physicsBody!.affectedByGravity = false
                bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
                bullet.physicsBody!.contactTestBitMask = kInvaderCategory
                bullet.physicsBody!.collisionBitMask = 0x0
                break
            //case for enemies firing
            case .InvaderFired:
                bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
                bullet.name = kInvaderFiredBulletName
                bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
                bullet.physicsBody!.dynamic = true
                bullet.physicsBody!.affectedByGravity = false
                bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
                bullet.physicsBody!.contactTestBitMask = kShipCategory
                bullet.physicsBody!.collisionBitMask = 0x0
                break
        }
        
        return bullet
    }
    
    func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
        // 1
        let bulletAction = SKAction.sequence([
            SKAction.moveTo(destination, duration: duration),
            SKAction.waitForDuration(3.0 / 60.0), SKAction.removeFromParent()
            ])
        
        // 2
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // 3
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        // 4
        addChild(bullet)
    }
    
    func fireShipBullets() {
        let existingBullet = childNodeWithName(kShipFiredBulletName)
        
        // 1
        if existingBullet == nil {
            if let ship = childNodeWithName(kShipName)
            {
                let bullet = makeBulletOfType(.ShipFired)
                // 2
                bullet.position = CGPoint(
                    x: ship.position.x,
                    y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
                )
                // 3
                let bulletDestination = CGPoint(
                    x: ship.position.x,
                    y: frame.size.height + bullet.frame.size.height / 2
                )
                // 4
                fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "shoot.mp3")
            }
        }
        else
        {
            if let ship = childNodeWithName(kShipName)
            {
                let bullet = makeBulletOfType(.ShipFired)
                // 2
                bullet.position = CGPoint(
                    x: ship.position.x,
                    y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
                )
                // 3
                let bulletDestination = CGPoint(
                    x: ship.position.x,
                    y: frame.size.height + bullet.frame.size.height / 2
                )
                // 4
                fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "shoot.mp3")
            }
        }
    }
    
    
    //invader bullets
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        let existingBullet = childNodeWithName(kInvaderFiredBulletName)
        
        // 1
        if existingBullet == nil {
            var allInvaders = Array<SKNode>()
            
            // 2
            enumerateChildNodesWithName(EnemyType.name) {
                node, stop in
                
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                // 3
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                
                let invader = allInvaders[allInvadersIndex]
                
                // 4
                let bullet = makeBulletOfType(.InvaderFired)
                bullet.position = CGPoint(
                    x: invader.position.x,
                    y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
                )
                
                // 5
                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
                
                // 6
                fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "bullet.wav")
            }
        }
    }
    
    //////////////////////////////////////////////////////
    
    override func update(currentTime: NSTimeInterval)
    {
        if isGameOver() {
            endGame()
        }
        
        processContactsForUpdate(currentTime)
        fireInvaderBulletsForUpdate(currentTime)
        processUserTapsForUpdate(currentTime)
        moveInvadersForUpdate(currentTime)
        processUserMotionForUpdate(currentTime)
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval)
    {
        // 1
        if let ship = childNodeWithName(kShipName) as? SKSpriteNode
        {
            // 2
            if let data = motionManager.accelerometerData
            {
                // 3
                if fabs(data.acceleration.x) > 0.1
                {
                    // 4 How do you move the ship?
                    player.physicsBody!.applyForce(CGVectorMake(20.0 * CGFloat(data.acceleration.x), 0))
                }
            }
        }
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        // 1
        for tapCount in tapQueue {
            if tapCount == 1 {
                // 2
                fireShipBullets()
            }
            // 3
            tapQueue.removeAtIndex(0)
        }
    }
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        for contact in contactQueue {
            handleContact(contact)
            
            if let index = contactQueue.indexOf(contact) {
                contactQueue.removeAtIndex(index)
            }
        }
    }
    
    //////////////HUD//////////////
    func setupHud()
    {
        // 1
        let scoreLabel = SKLabelNode(fontNamed: "Times New Roman")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 18
        
        // 2
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        // 3
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (80 + scoreLabel.frame.size.height/2)
        )
        addChild(scoreLabel)
        
        // 4
        let healthLabel = SKLabelNode(fontNamed: "Times New Roman")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 18
        
        // 5
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "Health: %.1f%%", shipHealth * 100.0)
        
        // 6
        healthLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (120 + healthLabel.frame.size.height/2)
        )
        addChild(healthLabel)
    }
    
    func adjustScoreBy(points: Int) {
        score += points
        
        if let score = childNodeWithName(kScoreHudName) as? SKLabelNode {
            score.text = String(format: "Score: %04u", self.score)
        }
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        // 1
        shipHealth = max(shipHealth + healthAdjustment, 0)
        
        if let health = childNodeWithName(kHealthHudName) as? SKLabelNode {
            health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        }
    }
    ////////////////////////////////////
    
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
}