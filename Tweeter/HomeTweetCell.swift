//
//  HomeTweetCell.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit
import AFNetworking


class HomeTweetCell: UITableViewCell {
    
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var tweet: Tweet! {
        didSet {
            retweetLabel.text = "TODO Jlee$$"
            nameLabel.text = tweet.user?.name
            usernameLabel.text = tweet.user?.screenname
            timestampLabel.text = tweet.sinceCreatedString
            tweetTextLabel.text = tweet.text
            profileImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        }
    }

    @IBAction func onReply(sender: AnyObject) {
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
    }
    
}
