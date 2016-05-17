//
//  LoginViewController.swift
//  finalProject
//
//  Created by Corrin, Will on 5/9/16.
//  Copyright © 2016 Corrin, Will. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("jbjbj")
        NSLog("dgdfg", "")
        
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            onLogin()
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.publishPermissions = ["publish_actions"]
            loginView.delegate = self
        }
    }
    
    func onLogin()
    {
        let navVC = self.storyboard!.instantiateViewControllerWithIdentifier("main_view") as! UINavigationController
        //let settingsVC = navVC.viewControllers[0] as! SettingsViewController
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods (for protocol)
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        print("User Logged In")
        onLogin()
        
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
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
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
    
}