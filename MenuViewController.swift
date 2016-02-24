//
//  MenuViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/23/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewControllers : [UIViewController] = []
    var menuTitle: [String] = []
    @IBOutlet weak var tableView: UITableView!
    var hamburgerViewController: HamburgerViewController?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        print("Menu View Controller: VIew did load")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let homeVC = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController")
        let profileVC = storyboard.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        profileVC.user = User.currentUser
        let mentionsVC = storyboard.instantiateViewControllerWithIdentifier("HomeNavigationController")
        
        viewControllers.append(homeVC)
        menuTitle.append("Home")
        viewControllers.append(profileVC)
        menuTitle.append("My Profile")
        viewControllers.append(mentionsVC)
        menuTitle.append("Mentions (Home)")
        
        menuTitle.append("Log out")
        
        hamburgerViewController?.contentViewController = viewControllers[0]
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        cell.titleLabel.text = menuTitle[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count + 1
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != viewControllers.count {
            hamburgerViewController?.contentViewController = viewControllers[indexPath.row]
        } else {
            User.currentUser?.logout()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
