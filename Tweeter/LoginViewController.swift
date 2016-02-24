//
//  ViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        User.loginWithCompletion() {
            (user: User?, error: NSError?) in
            if user != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let hamburgerViewController = storyboard.instantiateViewControllerWithIdentifier("HamburgerViewController") as! HamburgerViewController
                let menuViewController = storyboard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
                
                menuViewController.hamburgerViewController = hamburgerViewController
                hamburgerViewController.menuViewController = menuViewController
                self.presentViewController(hamburgerViewController, animated: true, completion: nil)
                
            } else {
                print(error)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

