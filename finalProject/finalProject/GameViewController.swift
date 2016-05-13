//
//  GameViewController.swift
//  finalProject
//
//  Created by Corrin, Will on 5/4/16.
//  Copyright (c) 2016 Corrin, Will. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        scene.viewController = self
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func gameOver()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}