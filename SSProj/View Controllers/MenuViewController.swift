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
    
    var numOfMedia: Int = 0
    var numOfFollowers: Int = 0
    var numOfFollowings: Int = 0

    var user: User? {
        didSet {
            if user != nil {
            
                var urlString = Instagram.Router.getRecent(self.user!.userID, self.user!.accessToken)
                println("TESTESTISNGSDG")
                getInfo(self.user!, request: urlString) {
                    NSLog("TOTAL POSTS: \(self.numOfMedia)")
                    NSLog("NUM OF POSTS \(self.user!.posts.count)")
                    //NSLog("TEST POST: \(self.user!.posts[0].likes.count)")
                    NSLog("NUM OF FOLLOWERS \(self.user!.followers.count)")
                    //NSLog("TEST FOLLOWERS: \(self.user!.followers[0])")
                    NSLog("NUM OF FOLLOWINGS \(self.user!.followings.count)")
                    //NSLog("TEST FOLLOWINGS: \(self.user!.followings[0])")
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
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    
                    var urlString = Instagram.Router.getCounts(user.userID, user.accessToken)
                    self.getCounts(user, request: urlString)
                    
                    //GET ALL MEDIA IDS
                    var mediaIDs: [String] = []
                
                    let posts = json["data"].arrayValue
                    
                    var i: Int
                    for (i = 0; i < posts.count; i++) {
                        let mediaID = posts[i]["id"].string
                        mediaIDs.append(mediaID!)
                    }
                    
                    
                    //GETS ALL LIKES/COMMENTS
                    for (i = 0; i < mediaIDs.count; i++) {
                        //GOES THROUGH EACH POST
                        //println(mediaIDs[i])
                        var urlString = Instagram.Router.getLikes(mediaIDs[i], user.accessToken)
                        self.getLikesInfo(user, mediaID: mediaIDs[i], request: urlString, callback: callback)
                    }
                    
                    
                    //GETS ALL FOLLOWERS
                    urlString = Instagram.Router.getFollowers(user.userID, user.accessToken)
                    self.makeFollowers(user, request: urlString)
                    
                    //GETS ALL FOLLOWINGS
                    urlString = Instagram.Router.getFollowings(user.userID, user.accessToken)
                    self.makeFollowings(user, request: urlString)
                    
                    NSLog("Done ALL")
                    callback()
                }
            }
        }

    }

    func getLikesInfo(user: User, mediaID: String, request: URLRequestConvertible, callback: () -> Void) {
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
                        //GOES THROUGH EACH LIKE ON POST
                        let likeID = json["data"][i]["id"].string
                        let likeUN = json["data"][i]["username"].string
                        var newLike: Like = Like(id: likeID!, un: likeUN!)
                        likesOnPost.append(newLike)
                    }
                        
                    
                    
                    let urlString = Instagram.Router.getComments(mediaID, user.accessToken)
                    self.getCommentsInfo(user, mediaID: mediaID, likes: likesOnPost, request: urlString, callback: callback)
                    
                    NSLog("DONE WITH COMPOST")
                    
                    
                }
                
            }
            
        }

    }
    
    func getCommentsInfo(user: User, mediaID: String, likes: [Like], request: URLRequestConvertible, callback: () -> Void) {
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
                            //GOES THROUGH EACH LIKE ON POST
                            let comID = json["data"][i]["from"]["id"].string
                            let comUN = json["data"][i]["from"]["username"].string
                            var newComment: Comment = Comment(id: comID!, un: comUN!)
                            commentsOnPost.append(newComment)
                        }
                        
                        self.makePost(user, mediaID: mediaID, likes: likes, comments: commentsOnPost, callback: callback)
                        NSLog("DONE WITH POST")
                        
                        
                    }
                    
                }
                
            }
            
        }
   
    }
    
    func makePost(user: User, mediaID: String, likes: [Like], comments: [Comment], callback: () -> Void) {
        //adds new post to User's posts
        var newPost: Post = Post(id: mediaID, l: likes, c: comments)
        user.posts.append(newPost)
        NSLog("POST MADE")
        callback()
    }
    
    func makeFollowers(user: User, request: URLRequestConvertible) {
        
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
                        }
                        
                    }
                    
                }
            
            }
            
        }
    
    func makeFollowings(user: User, request: URLRequestConvertible) {
        
        
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


}