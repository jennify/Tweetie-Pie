//
//  Tweet.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

//import Cocoa
import UIKit

var _currentTweets: [Tweet]?
var _mentionTweets: [Tweet]?
var currentTweetKey = "kCurrentTweetsKey"

class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var sinceCreatedString: String?
    var createAt: NSDate?
    var retweetedBy: User?
    var tweetID: UInt64?
    var retweeted: Bool?
    var favorited: Bool?
    var in_reply_to_screen_name: String?
    var dictionary: NSDictionary?
    var retweet_count: Int?
    var favorite_count: Int?
    
    var media_url: String?
    var media_height: Int?
    
    init(dictionary: NSDictionary) {
        var tweet_dictionary: NSDictionary = dictionary
        
        if tweet_dictionary["retweeted_status"] != nil {
            retweetedBy = User(dictionary: tweet_dictionary["user"] as! NSDictionary)
            tweet_dictionary = tweet_dictionary["retweeted_status"] as! NSDictionary
            
        }
        self.dictionary = tweet_dictionary
        if tweet_dictionary["entities"] != nil {
            
            let entities_dict = tweet_dictionary["entities"] as! NSDictionary
            if entities_dict["media"] != nil {
                let medias = entities_dict["media"] as! NSArray
                let media = medias[0] as! NSDictionary
                let media_url = media["media_url"] as! String
                self.media_url = media_url
            }
            
        }
        user = User(dictionary: tweet_dictionary["user"] as! NSDictionary)
        text = tweet_dictionary["text"] as? String
        createdAtString = tweet_dictionary["created_at"] as? String
        createAt = DateFormatter.dateFromString(createdAtString)
        sinceCreatedString = DateFormatter.sinceNowFormat(createAt)
        retweeted = tweet_dictionary["retweeted"] as? Bool
        favorited = tweet_dictionary["favorited"] as? Bool
        let id_str = tweet_dictionary["id_str"] as? String
        tweetID = UInt64(id_str!)
        
        self.in_reply_to_screen_name = tweet_dictionary["in_reply_to_screen_name"] as? String
        self.retweet_count = tweet_dictionary["retweet_count"] as? Int
        self.favorite_count = tweet_dictionary["favorite_count"] as? Int

    }
    
    func favorite(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.favorite("\(tweetID!)", completion: completion)
    }
    
    func unfavorite(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.unfavorite("\(tweetID!)", completion: completion)
    }
    
    func unretweet(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.unretweet("\(tweetID!)", completion: completion)
    }
    
    func retweet(completion: (tweet: Tweet?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.retweet("\(tweetID!)", completion: completion)
    }
    
    class func homeTimelineWithParams(parameters: NSDictionary?, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil , completion:  completion)
    }
    
    class func mentionsWithParams(parameters: NSDictionary?, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        TwitterClient.sharedInstance.mentionsWithParams(nil , completion:  completion)
    }
    
    class func loadMoreHomeTimelineWithLastTweet(lastTweet: Tweet, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        let max_id = NSNumber(unsignedLongLong: lastTweet.tweetID!)
        let params: NSDictionary = ["max_id": max_id]
        TwitterClient.sharedInstance.homeTimelineWithParams(params , completion:  completion)
    }
    
    class func loadMoreMentionsWithLastTweet(lastTweet: Tweet, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        let max_id = NSNumber(unsignedLongLong: lastTweet.tweetID!)
        let params: NSDictionary = ["max_id": max_id]
        TwitterClient.sharedInstance.mentionsWithParams(params , completion:  completion)
    }
    
    class func publishTweet(text: String, in_reply_tweet_id: UInt64?, completion: (tweets: Tweet?, error:NSError?) -> ()) {
        if text.characters.count > 0 {
            TwitterClient.sharedInstance.publishTweet(text,in_reply_tweet_id:in_reply_tweet_id, completion: completion)
        }
    }

    
    class func arrayWithTweets(tweets: [Tweet]) -> [NSDictionary]{
        var dataArray = [NSDictionary]()
        
        for tweet in tweets {
            dataArray.append(tweet.dictionary!)
        }
        return dataArray
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    class var currentTweets: [Tweet]? {
        get {
            if _currentTweets == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentTweetKey) as? NSData
                if data != nil {
                do {
                    if let tweetData = try NSJSONSerialization.JSONObjectWithData(data!,
                    options:NSJSONReadingOptions(rawValue:0)) as? [NSDictionary] {
                         _currentTweets = Tweet.tweetsWithArray(tweetData)
                    }
                } catch {
                _currentTweets = nil
                }
                }
            }
            return _currentTweets
        }
        
        set(tweets){
            _currentTweets = tweets
            if _currentTweets != nil {
                do {
                    let tweetData = arrayWithTweets(tweets!)
                    let data = try NSJSONSerialization.dataWithJSONObject(tweetData,
                        options:NSJSONWritingOptions(rawValue: 0))
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentTweetKey)
                    
                } catch {
                    print("Serialization Failed")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentTweetKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
    }
    
}
