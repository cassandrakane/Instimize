//
//  MenuViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/2/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Alamofire
import SwiftyJSON

class MenuViewController: UITabBarController {
    
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    var shouldLogin = false
    var nextURLRequest: NSURLRequest?
    let refreshControl = UIRefreshControl()
    var doneWithDownload: Bool = false
    var mediaIDs: [String] = []
    var followers: [Follower] = []
    var uniqFollowers = Set<Follower>()
    var followings: [Following] = []
    var count: Int = 0;
    
    
    var numOfMedia: Int = 0
    var numOfFollowers: Int = 0
    var numOfFollowings: Int = 0

    var user: User? {
        didSet {
            if user != nil {
                //var urlString = Instagram.Router.getCounts(self.user!.userID, self.user!.accessToken)
                //getCounts(self.user!, request: urlString)
                var urlString = Instagram.Router.getRecent(self.user!.userID, self.user!.accessToken)
                getInfo(self.user!, request: urlString) {
                    urlString = Instagram.Router.getFollowers(self.user!.userID, self.user!.accessToken)
                    self.getFollowers(self.user!, request: urlString) {
                        urlString = Instagram.Router.getFollowings(self.user!.userID, self.user!.accessToken)
                        self.getFollowings(self.user!, request: urlString) {
                            NSLog("NUM OF POSTS \(self.user!.posts.count)")
                            //NSLog("TEST POST: \(self.user!.posts[0].likes.count)")
                            NSLog("NUM OF FOLLOWERS \(self.user!.followers.count)")
                            //NSLog("TEST FOLLOWERS: \(self.user!.followers[0])")
                            NSLog("NUM OF FOLLOWINGS \(self.user!.followings.count)")
                            //NSLog("TEST FOLLOWINGS: \(self.user!.followings[0])")
                        }
                    }
                }
                hideLogoutButtonItem(false)
                
            } else {
                shouldLogin = true
                hideLogoutButtonItem(true)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu (segue : UIStoryboardSegue) {
        
    }

    
    func hideLogoutButtonItem(hide: Bool) {
        if hide {
            logoutButtonItem.title = ""
            logoutButtonItem.enabled = false
        } else {
            logoutButtonItem.title = "Logout"
            logoutButtonItem.enabled = true
        }
    }

    func requestAccessToken(code: String) {
        let request = Instagram.Router.requestAccessTokenURLStringAndParms(code)
        
        Alamofire.request(.POST, request.URLString, parameters: request.Params)
            .responseJSON {
                (_, _, jsonObject, error) in
                
                if (error == nil) {
                    //println(jsonObject)
                    let json = JSON(jsonObject!)
                    
                    if let accessToken = json["access_token"].string, userID = json["user"]["id"].string {
                        let user = User()
                        user.userID = userID
                        user.accessToken = accessToken
                        println("USER ID:" + user.userID)
                        println("ACCESS TOKEN:" + user.accessToken)
                        
                        /*
                        let realm = Realm()
                        realm.write() {
                        //FIGURE OUT L8TER
                        realm.add(user, update: true)
                        return
                        }
                        */
                        
                        self.performSegueWithIdentifier("unwindToMenu", sender: ["user": user])
                    }
                }
                
        }
    }
    
    
    //ACCESSING AND CREATING INFORMATION
    
    func getCounts(user: User, request: URLRequestConvertible) {
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
            
                    self.numOfMedia = String(stringInterpolationSegment: json["data"]["counts"]["media"]).toInt()!
                    self.numOfFollowers = String(stringInterpolationSegment: json["data"]["counts"]["followed_by"]).toInt()!
                    self.numOfFollowings = String(stringInterpolationSegment: json["data"]["counts"]["follows"]).toInt()!
                }
            }
        }

    }
    
    func getInfo(user: User, request: URLRequestConvertible, callback: () -> Void) {
        //GETS INFO FROM INSTAGRAM
        //println(request.URLRequest)
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                
                let json = JSON(jsonObject!)
                if (json["meta"]["code"].intValue  == 200) {
                    
                    println("Test 4")
                    //GET ALL MEDIA IDS
                
                    let posts = json["data"].arrayValue
                    
                    var i: Int
                    for (i = 0; i < posts.count; i++) {
                        let mediaID = posts[i]["id"].string!
                        self.mediaIDs.append(mediaID)
                    }
                    
                    println(self.mediaIDs)
                    
                    if let urlString = json["pagination"]["next_url"].URL {
                        println("NEXT PAG")
                        var nextURLRequest = NSURLRequest(URL: urlString)
                        println(nextURLRequest.URL)
                        self.getInfo(user, request: nextURLRequest) {
                            NSLog("Got More Posts")
                            callback()
                        }
                    } else {
                        //GETS ALL LIKES/COMMENTS
                        self.makeAllPosts(user, mediaIDs: self.mediaIDs) {
                            /*
                            //GETS ALL FOLLOWERS
                            NSLog("Done With All Posts")
                            var urlString = Instagram.Router.getFollowers(user.userID, user.accessToken)
                            self.makeFollowers(user, request: urlString) {
                                //GETS ALL FOLLOWINGS
                                urlString = Instagram.Router.getFollowings(user.userID, user.accessToken)
                                self.makeFollowings(user, request: urlString) {
                                    NSLog("done")
                                    callback()
                                }
                            }
                            */
                            NSLog("Done With All Posts")
                            callback()
                        }
                    }
                }
            }
        }
    }

    func getFollowers(user: User, request: URLRequestConvertible, callback: () -> Void) {
        
        //GETS INFO FROM INSTAGRAM
        //println(request.URLRequest)
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                
                let json = JSON(jsonObject!)
                if (json["meta"]["code"].intValue  == 200) {
                    
                    //GET ALL FOLlOWERS
                    
                    let followersInfo = json["data"].arrayValue
                    println(followersInfo)
                    
                    var i: Int
                    for (i = 0; i < followersInfo.count; i++) {
                        let followerID = followersInfo[i]["id"].string
                        let followerUN = followersInfo[i]["username"].string
                        let followerFN = followersInfo[i]["full_name"].string
                        var newFollower: Follower = Follower(id: followerID!, un: followerUN!, fn: followerFN!)
                        self.followers.append(newFollower)
                        NSLog("DONE WITH FOLLOWER")
                    }
                    
                    //println(self.followers)
                    
               
                    if let urlString = json["pagination"]["next_url"].URL {
                        println("NEXT PAG")
                        var nextURLRequest = NSURLRequest(URL: urlString)
                        println(nextURLRequest.URL)
                        self.getFollowers(user, request: nextURLRequest) {
                            NSLog("Got More Followers")
                            callback()
                        }
                    } else {
                        user.followers = self.followers
                        callback()
                    }
                    
                }
            }
        }

    }
    
    func getFollowings(user: User, request: URLRequestConvertible, callback: () -> Void) {
        //GETS INFO FROM INSTAGRAM
        //println(request.URLRequest)
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                
                let json = JSON(jsonObject!)
                if (json["meta"]["code"].intValue  == 200) {
                    
                    //GET ALL FOLLOWINGS
                    
                    let followingsInfo = json["data"].arrayValue
                    
                    var i: Int
                    for (i = 0; i < followingsInfo.count; i++) {
                        let followingID = followingsInfo[i]["id"].string
                        let followingUN = followingsInfo[i]["username"].string
                        let followingFN = followingsInfo[i]["full_name"].string
                        var newFollowing: Following = Following(id: followingID!, un: followingUN!, fn: followingFN!)
                        self.followings.append(newFollowing)
                        NSLog("DONE WITH FOLLOWING")
                    }
                    
                    println(self.followings)
                    
                    
                    if let urlString = json["pagination"]["next_url"].URL {
                        println("NEXT PAG")
                        var nextURLRequest = NSURLRequest(URL: urlString)
                        println(nextURLRequest.URL)
                        self.getFollowings(user, request: nextURLRequest) {
                            NSLog("Got More Followings")
                            callback()
                        }
                    } else {
                        user.followings = self.followings
                        callback()
                    }

                }
            }
        }
        
    }
    
    func makeAllPosts(user: User, mediaIDs: [String], callback: () -> Void) {
        //GETS ALL LIKES/COMMENTS
        var i: Int
        self.count = self.mediaIDs.count
        for (i = 0; i < self.mediaIDs.count; i++) {
            //GOES THROUGH EACH POST
            var newPost: Post = Post(id: "", l: [], c: [])
            let mediaID: String = self.mediaIDs[i]
            var urlString = Instagram.Router.getLikes(mediaID, user.accessToken)
            addLikes(user, mediaID: mediaID, post: newPost, request: urlString) {
                urlString = Instagram.Router.getComments(mediaID, user.accessToken)
                self.addComments(user, mediaID: mediaID, post: newPost, request: urlString) {
                    user.posts.append(newPost)
                    NSLog("Finsihed Post #\(i+1)")
                    self.count--;
                    if self.count == 0 {
                        callback()
                    }
                }
            }
        }
        //callback()
    }
    
    func addLikes(user: User, mediaID: String, post: Post, request: URLRequestConvertible, callback: () -> Void) {
        //GETS LIKES
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    
                    var likesOnPost: [Like] = []
                    var i: Int
                    for (i = 0; i < json["data"].count; i++) {
                        NSLog("test Like")
                        //GOES THROUGH EACH LIKE ON POST
                        let likeID = json["data"][i]["id"].string
                        let likeUN = json["data"][i]["username"].string
                        var newLike: Like = Like(id: likeID!, un: likeUN!)
                        likesOnPost.append(newLike)
                    }
                    
                    post.likes = likesOnPost
                    
                    callback()
                }
                
            }
            
        }

    }
    
    func addComments(user: User, mediaID: String, post: Post, request: URLRequestConvertible, callback: () -> Void) {
        //GETS COMMENTS
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        var commentsOnPost: [Comment] = []
                        var i: Int
                        for (i = 0; i < json["data"].count; i++) {
                            NSLog("test Com")
                            //GOES THROUGH EACH LIKE ON POST
                            let comID = json["data"][i]["from"]["id"].string
                            let comUN = json["data"][i]["from"]["username"].string
                            var newComment: Comment = Comment(id: comID!, un: comUN!)
                            commentsOnPost.append(newComment)
                        }
                        
                        post.comments = commentsOnPost
                        
                        callback()
                        
                    }
                    
                }
                
            }
            
        }
   
    }
    
    func makeFollowers(user: User, request: URLRequestConvertible, callback: () -> Void) {
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                        
                    let followers = json["data"].arrayValue
                        
                    var i: Int
                    for (i = 0; i < followers.count; i++) {
                        let followerID = followers[i]["id"].string
                        let followerUN = followers[i]["username"].string
                        let followerFN = followers[i]["full_name"].string
                        var newFollower: Follower = Follower(id: followerID!, un: followerUN!, fn: followerFN!)
                        user.followers.append(newFollower)
                        NSLog("DONE WITH FOLLOWER")
                    }
                    
                    callback()
                        
                }
                    
            }
            
        }
            
    }
    
    func makeFollowings(user: User, request: URLRequestConvertible, callback: () -> Void) {
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                if (json["meta"]["code"].intValue  == 200) {
                        
                    let followings = json["data"].arrayValue
                    var i: Int
                    for (i = 0; i < followings.count; i++) {
                        let followingID = followings[i]["id"].string
                        let followingUN = followings[i]["username"].string
                        let followingFN = followings[i]["full_name"].string
                        var newFollowing: Following = Following(id: followingID!, un: followingUN!, fn: followingFN!)
                        user.followings.append(newFollowing)
                        NSLog("DONE WITH FOLLOWING")
                    }
                    
                    callback()
                }
            
            }

        }
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