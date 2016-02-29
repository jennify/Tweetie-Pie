//
//  UserStateCell.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/26/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class UserStateCell: UITableViewCell {

    @IBOutlet weak var userStatTimelineSegment: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    var followersCount: Int? {
        didSet {
            self.followersCountLabel.text = "\(followersCount!)"
        }
    }
    var user: User!
    var followed: Bool? {
        didSet {
            var imageName = "follow-user"
            if followed == true {
                imageName = "unfollow-user"
            }
            
            self.followButton.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
            
        }
    }
    @IBAction func onFollow(sender: AnyObject) {
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
    
    @IBAction func onUserStatTimelineSegmentChanged(sender: AnyObject) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
