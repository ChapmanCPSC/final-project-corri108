//
//  GameScene.swift
//  finalProject
//
//  Created by Corrin, Will on 5/4/16.
//  Copyright (c) 2016 Corrin, Will. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    //create player outside so we can use it in other methods
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    override func didMoveToView(view: SKView)
    {
        //create and add background
        let background = SKSpriteNode(imageNamed: "spacebackground")
        background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(background)
        
        //set initial player position
        player.position = CGPoint(x: size.width * 0.5, y: player.size.height)
        addChild(player)
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
    }
    
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    func addMonster()
    {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "enemyShip")
        
        // Determine where to spawn the ship along the X axis
        let actualX = random(min: monster.size.width/2, max: size.width - monster.size.width/2)
        monster.position = CGPoint(x: actualX, y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(4.5), max: CGFloat(8.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: actualX, y: -monster.size.height/2), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
}