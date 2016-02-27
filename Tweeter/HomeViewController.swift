//
//  HomeViewController.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

let kHamburgerPressed = "kHamburgerPressed"
enum HomeViewControllerStyle {
    case MENTIONS, HOME
}
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeTweetCellDelegate, TweetCellDelegate {
    var tweets: [Tweet]?
    @IBOutlet weak var tableView: UITableView!
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var style: HomeViewControllerStyle!

    var hideFooterView: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(TweetCell.self, forCellReuseIdentifier: "TweetCell")
        
        self.refreshControlInit()
        self.scrollViewInit()
//        Tweet.currentTweets = nil
        
        // Network request to get initial data + Caching.
        getHomeTimelineWithCompletion {
            (tweets: [Tweet]?, error: NSError?) in
            self.tweets = tweets
            Tweet.currentTweets = tweets
            self.hideFooterView = tweets?.count > 0
            self.tableView.reloadData()
        }
        
        // Add observer for any new tweets created by current user.
        NSNotificationCenter.defaultCenter().addObserverForName(tweetCreatedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            let createdTweet = notification.userInfo?[tweetCreatedKey] as? Tweet
            if createdTweet != nil {
                self.tweets?.insert(createdTweet!, atIndex: 0)
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onHamburger(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kHamburgerPressed, object: nil)
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView: UIView! = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width))
        
        let sorryImageView: UIImageView = UIImageView(image: UIImage(named: "sad-face"))
        sorryImageView.center = footerView.center
        footerView.addSubview(sorryImageView)
        
        let sorryLabel = UILabel()
        sorryLabel.text = "No tweets to show."
        sorryLabel.textColor = UIColor.lightGrayColor()
        sorryLabel.sizeToFit()
        sorryLabel.center = CGPoint(x: footerView.center.x, y: footerView.center.y + 100 )
        footerView.addSubview(sorryLabel)
        
        footerView.hidden = self.hideFooterView
        return footerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destViewController = segue.destinationViewController

        if segue.identifier == "replySegue" {
            
            let button = sender as? UIButton
            let cell = button?.superview?.superview as? HomeTweetCell
            
            let navigationController = destViewController as? UINavigationController
            let composerViewController = navigationController?.topViewController as? ComposeViewController
            composerViewController?.inReplyToTweet = cell?.tweet

        } else if segue.identifier == "detailsSegue" {
            let cell = sender as? HomeTweetCell
            let detailsViewController = destViewController as? TweetViewController
            detailsViewController?.tweet = cell?.tweet
            
        } else if segue.identifier == "userProfileFromHomeSegue" {
            let cell = sender as? HomeTweetCell
            let profileViewController = destViewController as? UserProfileViewController
            profileViewController?.user = cell?.tweet.user
            
        }
    }

    func getHomeTimelineWithCompletion(completion: ([Tweet]?,NSError?) -> Void) {
        
        if Tweet.currentTweets == nil {
            if self.style == HomeViewControllerStyle.HOME {
                Tweet.homeTimelineWithParams(nil, completion: completion)
            } else if self.style == HomeViewControllerStyle.MENTIONS {
                Tweet.mentionsWithParams(nil, completion: completion)
            }
        } else {
            self.tweets = Tweet.currentTweets
            self.hideFooterView = tweets?.count > 0
            completion(self.tweets, nil)
            self.tableView.reloadData()
            print("Loading cached")
        }
        
    }
    
    func loadMoreTimelineWithCompletion(completion: ([Tweet]?,NSError?) -> Void) {
        let lastTweet = self.tweets?.last
        if self.style == HomeViewControllerStyle.HOME {
            Tweet.loadMoreHomeTimelineWithLastTweet(lastTweet!, completion: completion)
        } else if self.style == HomeViewControllerStyle.MENTIONS {
            Tweet.loadMoreMentionsWithLastTweet(lastTweet!, completion: completion)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
//        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTweetCell", forIndexPath: indexPath) as! HomeTweetCell
        cell.delegate = self
        cell.tweet = self.tweets![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func performSegueToIdentifier(identifier: String, sender: TweetCell) {
        self.performSegueWithIdentifier(identifier, sender: sender)
    }
    
    func performSegueToIdentifierHome(identifier: String, sender: HomeTweetCell) {
        self.performSegueWithIdentifier(identifier, sender: sender)
    }

}

extension HomeViewController {
    // Extension for refresh.
    
    func refreshControlInit() {
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        getHomeTimelineWithCompletion() {
            (refreshed_tweets: [Tweet]?, error: NSError?) in
            if refreshed_tweets != nil {
                self.tweets = refreshed_tweets
                Tweet.currentTweets = refreshed_tweets
                self.hideFooterView = refreshed_tweets?.count > 0
                self.tableView.reloadData()
            } else {
                print(error)
            }
            refreshControl.endRefreshing()
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    // Extension for Infinite scroll.
    
    func scrollViewInit() {
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                if self.tweets?.count > 0 {
                    loadMoreTimelineWithCompletion() {
                            (tweets: [Tweet]?, error: NSError?) in
                            if tweets != nil {
                                self.tweets?.appendContentsOf(tweets!)
                                self.hideFooterView = tweets?.count > 0
                                self.loadingMoreView!.stopAnimating()
                                self.tableView.reloadData()
                                
                            } else {
                                print("\(error)")
                            }
                            self.isMoreDataLoading = false
                        }
                    
                } else {
                    getHomeTimelineWithCompletion() {
                        (tweets: [Tweet]?, error: NSError?) in
                        if tweets != nil {
                            self.tweets = tweets
                            self.hideFooterView = tweets?.count > 0
                            self.loadingMoreView!.stopAnimating()
                            self.tableView.reloadData()
                            Tweet.currentTweets = tweets
                            
                        } else {
                            print(error)
                        }
                        self.isMoreDataLoading = false
                    }
                }
            }
        }
    }

}