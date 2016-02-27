//
//  TweetViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    var user: User?
    
    var retweetCount: Int! {
        didSet {
            retweetCountLabel.text = "\(retweetCount!)"
        }
    }
    var favoriteCount: Int! {
        didSet {
            favoriteCountLabel.text = "\(favoriteCount!)"
        }
    }
    
    var favorited: Bool! {
        didSet {
            var imageName = "like-action"
            if favorited == true {
                imageName = "like-action-on-pressed-red"
                favoriteCount = favoriteCount + 1
            } else {
                favoriteCount = favoriteCount - 1
            }
            self.favoriteButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        }
    }
    var retweeted: Bool! {
        didSet {
            var imageName = "retweet-default"
            if retweeted == true {
                imageName = "retweet-pressed-green"
                retweetCount = retweetCount + 1
            } else {
                retweetCount = retweetCount - 1
            }
            self.retweetButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        }
    }
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    var tweet: Tweet!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameLabel.text = tweet.user?.name
        if tweet.user?.screenname != nil {
            usernameLabel.text = "@" + (tweet.user?.screenname)!
        }

        
        retweetCount = tweet.retweet_count
        favoriteCount = tweet.favorite_count
        timestampLabel.text = tweet.sinceCreatedString
        tweetTextLabel.text = tweet.text
        profileImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true

        // Set up gestures to UIImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: "profileImageTapped:")
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.userInteractionEnabled = true
        
        if tweet.retweetedBy != nil {
            retweetLabel.text = "@" + tweet.retweetedBy!.screenname! + " retweeted"
            retweetLabel.hidden = false
        } else if tweet.in_reply_to_screen_name != nil {
            retweetLabel.text = "In reply to @" + (tweet.in_reply_to_screen_name)!
            retweetLabel.hidden = false
        } else {
            retweetLabel.hidden = true
            retweetLabel.text = ""
        }
        user = tweet.user
        
        // Set state variables.
        favorited = tweet.favorited
        retweeted = tweet.retweeted
        
        // Set up "hover" images for buttons.
        favoriteButton.setImage(UIImage(named: "like-action-hover"), forState: UIControlState.Highlighted)
        retweetButton.setImage(UIImage(named: "retweet-hover"), forState: UIControlState.Highlighted)
    
    }

    func profileImageTapped(gesture: UIGestureRecognizer) {
        if let _ = gesture.view as? UIImageView {
            self.performSegueWithIdentifier("userProfileFromDetailsSegue", sender: self)
        }
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if self.retweeted == false {
            tweet.retweet() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.retweeted = true
                } else {
                    print(error)
                }
                
            }
        } else {
            tweet.unretweet() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.retweeted = false
                } else {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if self.favorited == false {
            tweet.favorite() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.favorited = true
                } else {
                    print(error)
                }
            }
        } else {
            tweet.unfavorite() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.favorited = false
                } else {
                    print(error)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destViewController = segue.destinationViewController
        
        if segue.identifier == "replyDetailTweetSegue" || segue.identifier == "replyDetailBarTweetSegue" {
            let navigationController = destViewController as? UINavigationController
            let composerViewController = navigationController?.topViewController as? ComposeViewController
            composerViewController?.inReplyToTweet = self.tweet
        } else if segue.identifier == "userProfileFromDetailsSegue" {
            let vc = sender as? TweetViewController
            let profileViewController = destViewController as? UserProfileViewController
            profileViewController?.user = vc?.user
            
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
