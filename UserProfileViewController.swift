//
//  UserProfileViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/23/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate {
    var user: User?
    @IBOutlet weak var tableView: UITableView!
    var originalBannerHeight: CGFloat = 100.0
    var currentBannerHeight: CGFloat = 100.0
    var destinationBannerHeight:CGFloat = 50.0
    var bannerImageView: UIImageView!
    var profileImageView: UIImageView!
    var blurView: UIVisualEffectView?
    var headerView: UITableViewHeaderFooterView!
    var headerNameLabel: UILabel!
    var profileTransform: CGAffineTransform!
    var tweets: [Tweet]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        tableView.estimatedSectionHeaderHeight = originalBannerHeight;
        tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "TweetCell")

        originalBannerHeight = 200
        currentBannerHeight = originalBannerHeight

        self.navigationController?.navigationBarHidden = true

        Tweet.userTweets(self.user?.screenname) {
            (tweet: [Tweet]?, error: NSError?) in
            if error == nil {
                self.tweets = tweet
                self.tableView.reloadData()
            } else {
                print(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Initialize header
        let header = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: originalBannerHeight))
        
        // Banner Image.
        let bannerImageView = UIImageView(frame: header.bounds)
        bannerImageView.contentMode = .ScaleAspectFill
        bannerImageView.clipsToBounds = true
        if user?.bannerImageUrl != nil {
            bannerImageView.setImageWithURL(NSURL(string: (user?.bannerImageUrl!)!)!)
        } else {
            bannerImageView.backgroundColor = UIColor.initWithHex("55ACEE")
        }
        self.bannerImageView = bannerImageView
        
        // Profile Image
        let profileImageView = UIImageView()
        profileImageView.frame = CGRect(x: 0, y: 0, width: 65, height: 65)
        profileImageView.center = CGPoint(x: bannerImageView.center.x, y: bannerImageView.frame.height + 20)
        profileImageView.setImageWithURL(NSURL(string: (user?.profileImageUrl!)!)!)
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.borderWidth = 2.0
        self.profileImageView = profileImageView
        self.profileTransform = self.profileImageView.transform
        
        header.userInteractionEnabled = true
        let backButton = UIButton()
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.userInteractionEnabled = true
        backButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "onBackButton:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.frame = CGRect(x: 8, y: 8, width: 50, height: 50)
        backButton.sizeToFit()
        
        // Add subviews
        header.addSubview(bannerImageView)
        header.addSubview(profileImageView)
        header.addSubview(backButton)
        header.bringSubviewToFront(backButton)
        
        self.headerView = header
        return header
    }
    
    func onBackButton(sender: UIButton) {
        
        if self.user!.name == User.currentUser!.name {
            NSNotificationCenter.defaultCenter().postNotificationName(kHamburgerPressed, object: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
            self.navigationController?.navigationBarHidden = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performSegueToIdentifierHome(identifier: String, sender: TweetCell) {
        self.performSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "replySegue" {
            let cell = sender as! TweetCell
            let destViewController = segue.destinationViewController
            let navigationController = destViewController as? UINavigationController
            let composerViewController = navigationController?.topViewController as? ComposeViewController
            composerViewController?.inReplyToTweet = cell.tweet
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row >= 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
            cell.delegate = self
            cell.tweet = self.tweets?[indexPath.row - 1]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("UserStatsCell") as! UserStateCell
            cell.user = user
            cell.nameLabel.text = user?.name
            cell.usernameLabel.text = "@\(user!.screenname!)"
            cell.followersCount = user!.followers_count!
            cell.followingCountLabel.text = "\(user!.following_count!)"
            cell.tweetCountLabel.text = "\(user!.tweet_count!)"
            cell.followed = user!.following!
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tweets?.count ?? 0) + 1
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView: UIView! = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        return footerView
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

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

        let yOffset = scrollView.contentOffset.y + 44
        
        if yOffset < 0  {
            currentBannerHeight = originalBannerHeight - yOffset
            updateBanner(yOffset)
            
        } else if(yOffset < originalBannerHeight - destinationBannerHeight) {
            currentBannerHeight = originalBannerHeight - yOffset
            updateBanner(nil)
            removeBlurView()
            
        } else {
            currentBannerHeight = destinationBannerHeight
            updateBanner(nil)
            addBlurView()
        }

    }
    
    func updateBanner(yOffset: CGFloat?) {
        var profileAdjustY: CGFloat = 0.0
        var y: CGFloat = 0.0
        if yOffset != nil {
            if yOffset < 0 {
                profileAdjustY = yOffset!
            }
            y = yOffset!
        }
        
        self.bannerImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: currentBannerHeight)
        self.profileImageView.center = CGPoint(x: self.view.frame.width/2.0, y:currentBannerHeight + 20 + profileAdjustY)
        self.blurView?.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: currentBannerHeight)
    }
    
    func addBlurView() {
        if blurView == nil {
            let destFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: destinationBannerHeight)
            let blurView = UIVisualEffectView(frame: destFrame)
            let blurEffect = UIBlurEffect(style: .Light)
            blurView.alpha = 0.8
            
            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(frame:destFrame)
            vibrancyView.alpha = 0.8
     
            
            self.bannerImageView.addSubview(blurView)
            self.bannerImageView.addSubview(vibrancyView)
            
            let nameLabel = UILabel()
            nameLabel.text = self.user?.name
            nameLabel.textColor = UIColor.whiteColor()
            nameLabel.sizeToFit()
            nameLabel.center = CGPoint(x: self.view.frame.width/2.0 , y: destinationBannerHeight/2.0)
            self.headerNameLabel = nameLabel
            
            
            UIView.transitionWithView(self.profileImageView, duration: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                blurView.effect = blurEffect
                vibrancyView.effect = vibrancyEffect
                self.bannerImageView.addSubview(self.headerNameLabel)
            }, completion:  nil)

            UIView.transitionWithView(self.profileImageView, duration: 2.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.profileImageView.transform = CGAffineTransformScale(self.profileImageView.transform, 1.0, 0.0)
                }, completion: nil)

            self.blurView = blurView
        }


    }
    func removeBlurView() {
        if self.blurView != nil {
            UIView.animateWithDuration(0.3, animations: {
                self.blurView?.alpha = 0.0
                self.headerNameLabel.removeFromSuperview()
            }, completion: {
                (result: Bool) in
                self.blurView?.removeFromSuperview()
                self.blurView = nil
            })
            
            
            UIView.transitionWithView(self.profileImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.profileImageView.transform = self.profileTransform

            }, completion: nil)

        }
    }
    

}

