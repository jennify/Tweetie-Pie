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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    var favorited: Bool?
    var retweeted: Bool?
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    var tweet: Tweet!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameLabel.text = tweet.user?.name
        if tweet.user?.screenname != nil {
            usernameLabel.text = "@" + (tweet.user?.screenname)!
        }
        timestampLabel.text = tweet.sinceCreatedString
        tweetTextLabel.text = tweet.text
        profileImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        
        if tweet.retweetedBy != nil {
            retweetLabel.text = "@" + (tweet.retweetedBy?.screenname)! + " retweeted"
//            retweetLabel.hidden = false
        } else if tweet.in_reply_to_screen_name != nil {
            retweetLabel.text = "In reply to @" + (tweet.in_reply_to_screen_name)!
//            retweetLabel.hidden = false
        } else {
//            retweetLabel.hidden = true
//            retweetLabel.text = ""
        }
//
        // Set state variables.
        favorited = tweet.favorited
        retweeted = tweet.retweeted
        
        // Set up "hover" images for buttons.
        favoriteButton.setImage(UIImage(named: "like-action-hover"), forState: UIControlState.Highlighted)
        retweetButton.setImage(UIImage(named: "retweet-hover"), forState: UIControlState.Highlighted)
    
        retweetCountLabel.text = "\(tweet.retweet_count!)"
        favoriteCountLabel.text = "\(tweet.favorite_count!)"
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
                    print("error")
                }
            }
        } else {
            tweet.unfavorite() {
                (tweet:Tweet?, error:NSError?) in
                if error == nil {
                    self.favorited = false
                } else {
                    print("error")
                }
            }
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
