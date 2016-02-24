//
//  UserProfileViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/23/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    var user: User?
    
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var follow: UIButton!
    
    var followersCount: Int? {
        didSet {
            self.followersCountLabel.text = "\(followersCount!)"
        }
    }
    
    var followed: Bool? {
        didSet {
            var imageName = "follow-user"
            if followed == true {
                imageName = "unfollow-user"
            }
            self.follow.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
     
        }
    }
    @IBAction func onFollowUser(sender: AnyObject) {
        if self.followed == false {
            self.user!.follow() {
                (user:User?, error:NSError?) in
                if error == nil {
                    self.followed = true
                    self.followersCount = self.followersCount! + 1
                }
            }
        } else {
            self.user!.unfollow() {
                (user:User?, error:NSError?) in
                if error == nil {
                    self.followed = false
                    self.followersCount = self.followersCount! - 1
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            nameLabel.text = user?.name
            usernameLabel.text = user?.screenname
            profileImageView.setImageWithURL(NSURL(string: user!.profileImageUrl!)!)
            followersCount = user!.followers_count!
            followingCountLabel.text = "\(user!.following_count!)"
            tweetCountLabel.text = "\(user!.tweet_count!)"
            followed = user!.following!
        }

        // Do any additional setup after loading the view.
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
