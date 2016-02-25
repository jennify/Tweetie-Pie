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
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HomeTweetCellDelegate {
    var tweets: [Tweet]?
    @IBOutlet weak var tableView: UITableView!
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var style: HomeViewControllerStyle!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControlInit()
        self.scrollViewInit()
        
        // Network request to get initial data + Caching.
        if Tweet.currentTweets == nil {
            getHomeTimelineWithCompletion {
                (tweets: [Tweet]?, error: NSError?) in
                self.tweets = tweets
                Tweet.currentTweets = tweets
                print("Caching")
                self.tableView.reloadData()
            }
        } else {
            self.tweets = Tweet.currentTweets
            print("Loading cached")
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
        if self.style == HomeViewControllerStyle.HOME {
            Tweet.homeTimelineWithParams(nil, completion: completion)
        } else if self.style == HomeViewControllerStyle.MENTIONS {
            Tweet.mentionsWithParams(nil, completion: completion)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTweetCell", forIndexPath: indexPath) as! HomeTweetCell
        cell.delegate = self
        cell.tweet = self.tweets![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func performSegueToIdentifier(identifier: String, sender: HomeTweetCell) {
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
                if self.style == HomeViewControllerStyle.HOME {
                    Tweet.loadMoreHomeTimelineWithLastTweet((self.tweets?.last)!) {
                        (tweets: [Tweet]?, error: NSError?) in
                        if tweets != nil {
                            self.tweets?.appendContentsOf(tweets!)
                            self.loadingMoreView!.stopAnimating()
                            self.tableView.reloadData()
                            self.isMoreDataLoading = false
                        } else {
                            print("\(error)")
                        }
                    }
                } else if self.style == HomeViewControllerStyle.MENTIONS {
                    Tweet.loadMoreMentionsWithLastTweet((self.tweets?.last)!) {
                        (tweets: [Tweet]?, error: NSError?) in
                        if tweets != nil {
                            self.tweets?.appendContentsOf(tweets!)
                            self.loadingMoreView!.stopAnimating()
                            self.tableView.reloadData()
                            self.isMoreDataLoading = false
                        } else {
                            print("\(error)")
                        }
                    }
                }
            }
        }
    }

}