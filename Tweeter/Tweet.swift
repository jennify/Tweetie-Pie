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
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        createdAtString = dictionary["created_at"] as? String
        createAt = DateFormatter.dateFromString(createdAtString)
        sinceCreatedString = DateFormatter.sinceNowFormat(createAt)
        
//        retweetedBy =
        
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
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}
