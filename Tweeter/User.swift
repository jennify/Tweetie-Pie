//
//  User.swift
//  Tweeter
//
//  Created by Jennifer Lee on 2/18/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

var _currentUser: User?
var currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary!
    var following: Bool?
    var followers_count: Int?
    var following_count: Int?
    var tweet_count: Int?
    var recent_tweet: Tweet?
    var bannerImageUrl: String?
//    var profileBackgroundImageColor: String?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        following = dictionary["following"] as? Bool
        followers_count = dictionary["followers_count"] as? Int
        following_count = dictionary["friends_count"] as? Int
        tweet_count = dictionary["statuses_count"] as? Int
        
//        profileBackgroundImageColor = dictionary["profile_background_color"] as? String
//        backgroundImageUrl = dictionary["profile_background_image_url"] as? String

        bannerImageUrl = dictionary["profile_banner_url"] as? String
    }
    
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.loginWithCompletion(completion)
    }
    
    func follow(completion: (User?, NSError?) -> Void) {
        TwitterClient.sharedInstance.follow(screenname!, completion: completion)
    }
    
    func unfollow(completion: (User?, NSError?) -> Void) {
        TwitterClient.sharedInstance.unfollow(screenname!, completion: completion)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    do {
                        if let dictionary = try NSJSONSerialization.JSONObjectWithData(data!,
                            options:NSJSONReadingOptions(rawValue:0)) as? [String:AnyObject] {
        _currentUser = User(dictionary: dictionary)
        }
        
                    } catch {
                        _currentUser = nil
                    }
                }
            }
            return _currentUser
        }
        
        set(user){
            _currentUser = user
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary,
                        options:NSJSONWritingOptions(rawValue: 0))
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                    
                    
                } catch {
                    print("Serialization Failed")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()

        }
    }
}
