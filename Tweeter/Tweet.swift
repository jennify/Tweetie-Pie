//
//  Tweet.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

//import Cocoa
import UIKit


class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var sinceCreatedString: String?
    var createAt: NSDate?
    var retweetedBy: User?
    var tweetID: Int?
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        createAt = DateFormatter.dateFromString(createdAtString)
        sinceCreatedString = DateFormatter.sinceNowFormat(createAt)
        let id_str = dictionary["id_str"] as? String
        if id_str != nil {
            tweetID = Int(id_str!)
        }
        
    }
    
    
    
    func favorite() {
        
    }
    
    func reply() {
        
    }
    
    func retweet() {
        
    }
    
    class func homeTimelineWithParams(parameters: NSDictionary?, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil , completion:  completion)
    }
    
    class func loadMoreHomeTimelineWithLastTweet(lastTweet: Tweet, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {

        let params: NSDictionary = ["since_id": (lastTweet.tweetID)!]
        TwitterClient.sharedInstance.homeTimelineWithParams(params , completion:  completion)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
