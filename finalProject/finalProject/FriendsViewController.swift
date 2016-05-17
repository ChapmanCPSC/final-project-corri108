//
//  LoginViewController.swift
//  finalProject
//
//  Created by Corrin, Will on 5/9/16.
//  Copyright © 2016 Corrin, Will. All rights reserved.
//

import Foundation
import UIKit

class FriendsViewController: UIViewController
{
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var actualFriendLabel: UILabel!
    
    @IBAction func onBackClicked(sender: UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setYourScore()
        getFriends()
    }
    
    func setYourScore()
    {
        var yourID : String? = ""
        
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], HTTPMethod: "GET")
        req.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if(error == nil)
            {
                let bUserFacebookDict = result as! NSDictionary
                print("RESULT : \(result)")
                yourID = bUserFacebookDict["id"] as! String
            }
            else
            {
                print("error \(error)")
            }
        }
        
        let aHIscore = NSUserDefaults().valueForKey("hiscore") as! Int
        
        let fbRequest = FBSDKGraphRequest(graphPath: "/\(yourID)/scores", parameters: ["score" : aHIscore], HTTPMethod: "POST")
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            dispatch_async(dispatch_get_main_queue() , { () -> Void in
                if error == nil
                {
                    print("scores: \(result)")
                }
                else
                {
                    
                    print("Error Getting Scores \(error)");
                    
                }
            })
            
        }
        
        friendLabel.text = "You" + " : " + "        \(aHIscore)"
    }
    
    func getScoreFor(name : String, id : String) -> String
    {
        var ret : String = name + " : " + "        0"
        
        let fbRequest = FBSDKGraphRequest(graphPath: "/\(id)/scores", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
        
            dispatch_async(dispatch_get_main_queue() , { () -> Void in
                if error == nil
                {
                    print("scores: \(result)")
                    let bUserFacebookDict = result as! NSDictionary
                    if let score = bUserFacebookDict["score"] as? String
                    {
                        ret = name + " : " + "        \(score)"
                    }
                }
                else
                {
                    print("Error Getting Scores \(error)");
                }
            })
            
        }
        
        return ret
    }
    
    func getFriends()
    {
        self.actualFriendLabel.text = ""
        let fbRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            dispatch_async(dispatch_get_main_queue() , { () -> Void in
                if error == nil
                {
                    if let friendObjects = result["data"] as? [NSDictionary]
                    {
                        for friendObject in friendObjects
                        {
                            let friendName = friendObject["name"] as! String
                            let friendID = friendObject["id"] as! String
                            print(friendObject["id"] as! String)
                            print(friendObject["name"] as! String)
                            self.actualFriendLabel.text = self.actualFriendLabel.text! + self.getScoreFor(friendName, id: friendID)
                        }
                    }
                }
                else
                {
                    
                    print("Error Getting Friends \(error)");
                    
                }
            })
            
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}