//
//  LoginViewController.swift
//  finalProject
//
//  Created by Corrin, Will on 5/9/16.
//  Copyright © 2016 Corrin, Will. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MenuViewController: UIViewController, FBSDKLoginButtonDelegate  {
    
    @IBOutlet weak var recentScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBAction func onPlayClicked(sender: AnyObject)
    {
        let navVC = self.storyboard!.instantiateViewControllerWithIdentifier("game_view") as! UINavigationController
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    @IBAction func onExitClicked(sender: AnyObject)
    {
        exit(0)
    }
    @IBAction func onFriendsClicked(sender: AnyObject)
    {
        let navVC = self.storyboard!.instantiateViewControllerWithIdentifier("friend_view") as! UINavigationController
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        else
        {
            
        
        }
        
        playBGMusic()
        updateScore()
    }
    
    func updateScore()
    {
        let def = NSUserDefaults()
        var score = def.valueForKey("score") as? Int
        var HIscore = def.valueForKey("hiscore") as? Int
        
        if(score == nil || HIscore == nil)
        {
            //score stuff
            def.setInteger(0, forKey: "score")
            def.setInteger(0, forKey: "hiscore")
            
            score = 0
            HIscore = 0
            scoreLabel.text = "High Score: 0"
            recentScoreLabel.text = "Recent Score: 0"
        }
        else
        {
            let ascore = def.valueForKey("score") as! Int
            let aHIscore = def.valueForKey("hiscore") as! Int
            
            scoreLabel.text = "High Score: \(aHIscore)"
            recentScoreLabel.text = "Recent Score: \(ascore)"
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
         updateScore()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods (for protocol)
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                //print("YAYEEEEEEE");
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("User Logged Out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //get users data
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    //plays background music
    var player: AVAudioPlayer?
    
    func playBGMusic()
    {
        let url = NSBundle.mainBundle().URLForResource("bgmusic", withExtension: "mp3")!
        
        do
        {
            player = try AVAudioPlayer(contentsOfURL: url)
            guard let player = player else { return }
            
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
        }
        catch let error as NSError
        {
            print(error.description)
        }
    }
}