//
//  TwitterClient.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

//import Cocoa
import BDBOAuth1Manager

let twitterConsumerKey = "BRkKnlV1FpZ416t6P8sDjyQQm"
let twitterConsumerSecret = "hAtR2FelrUrrqpjezPDrtxt5EKfgl4VIN4BvhICPyj6PzL0sMs"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(
                baseURL: twitterBaseURL,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        self.loginCompletion = completion
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string:"tweetiepy://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
                let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(authURL!)
            }, failure: { (error: NSError! ) -> Void in
                print("Failed to get token")
        })
    }
    
    func homeTimelineWithParams(parameters: NSDictionary?, completion: (tweets: [Tweet]?, error:NSError?) -> ()) {
        
        GET("1.1/statuses/home_timeline.json", parameters: nil, success:  { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweets: nil, error: error)
        })
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got access token")
            
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success:  { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                    let user = User(dictionary: response as! NSDictionary)
                    User.currentUser = user
                    self.loginCompletion?(user:user, error:nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                    self.loginCompletion?(user:nil, error:error)
                    
            })

            }, failure: {
                (error: NSError!) -> Void in
                print("Failed to get access token")
                self.loginCompletion?(user:nil, error:error)
        })
    }
}