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

    var user: User? {
        didSet {
            if user != nil {
                var urlString = Instagram.Router.getRecent(user!.userID, user!.accessToken)
                getInfo(user!, request: urlString) {
                    NSLog("ANYTHING")
                    NSLog("NUM OF POSTS \(self.user!.posts.count)")
                    var i: Int
                    for (i = 0; i < self.user!.posts.count; i++) {
                        NSLog("MEDIA ID")
                        NSLog(self.user!.posts[i].mediaID)
                        NSLog("LIKES")
                        var j: Int
                        for (j = 0; j < self.user!.posts[i].likes.count; j++) {
                            NSLog(self.user!.posts[i].likes[j].likerUsername)
                        }
                        NSLog("COMMENTERS")
                        for (j = 0; j < self.user!.posts[i].comments.count; j++) {
                            NSLog(self.user!.posts[i].comments[j].commenterUsername)
                        }
                    }

                }
                
                /*
                println("ANYTHING")
                var i: Int
                for (i = 0; i < user!.posts.count; i++) {
                    println("MEDIA ID")
                    println(user!.posts[i].mediaID)
                    println("LIKES")
                    var j: Int
                    for (j = 0; j < user!.posts[i].likes.count; j++) {
                        println(user!.posts[i].likes[j].likerUsername)
                    }
                    println("COMMENTERS")
                    for (j = 0; j < user!.posts[i].comments.count; j++) {
                        println(user!.posts[i].comments[j].commenterUsername)
                    }
                }
                */
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
    
    
    
    func getInfoOther(user: User) {
        
        var i: Int
        
        //GET ALL MEDIA IDS
        var urlString = Instagram.Router.getRecent(user.userID, user.accessToken)
        getInfo(user, request: urlString) {
            
        }
        
                        
        //GET ALL FOLLOWERS
        urlString = Instagram.Router.getFollowers(user.userID, user.accessToken)
        var followersUN: [String]
        var followersFN: [String]
        (followersUN, followersFN) = getFollowers(urlString)
        
        println("FOLLOWERS:  \(followersUN)")
        println("FOLLOWERS (NAMES: \(followersFN)")
        
        //GET ALL FOLLOWINGS
        urlString = Instagram.Router.getFollowings(user.userID, user.accessToken)
        var followingsUN: [String]
        var followingsFN: [String]
        (followingsUN, followingsFN) = getFollowers(urlString)
        
        println("FOLLOWINGS:  \(followingsUN)")
        println("FOLLOWINGS (NAMES: \(followingsFN)")
        
        /*
                        
        let lastItem = self.photos.count
        self.photos.extend(photoInfos)
                        
        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        
        dispatch_async(dispatch_get_main_queue()) {
        self.collectionView!.insertItemsAtIndexPaths(indexPaths)
        }
        */
                        
    }
    
    
    func getInfo(user: User, request: URLRequestConvertible, callback: () -> Void) {
        //GETS INFO FROM INSTAGRAM
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    
                    
                    //GET ALL MEDIA IDS
                    var mediaIDs: [String] = []
                
                    let posts = json["data"].arrayValue
                    
                    var i: Int
                    for (i = 0; i < posts.count; i++) {
                        let mediaID = posts[i]["id"].string
                        mediaIDs.append(mediaID!)
                    }
                    
                    println("MEDIA IDS: ")
                    for (i = 0; i < mediaIDs.count; i++) {
                        //GOES THROUGH EACH POST
                        //println(mediaIDs[i])
                        var urlString = Instagram.Router.getLikes(mediaIDs[i], user.accessToken)
                        self.getLikesInfo(user, mediaID: mediaIDs[i], request: urlString, callback: callback)
                    }
                    NSLog("DONE WITH LIKECOMPOST")
                    
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
    
    
    
    func getFollowers(request: URLRequestConvertible) -> ([String], [String]){
        
        var followersUsername: [String] = []
        var followersFullName: [String] = []
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        let followers = json["data"].arrayValue
                        
                        var i: Int
                        for (i = 0; i < followers.count; i++) {
                            let followerUN = followers[i]["username"].string
                            let followerFN = followers[i]["full_name"].string
                            followersUsername.append(followerUN!)
                            followersFullName.append(followerFN!)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        return (followersUsername, followersFullName)

    }
    
    func getFollowings(request: URLRequestConvertible) -> ([String], [String]){
        
        var followingsUsername: [String] = []
        var followingsFullName: [String] = []
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        let followings = json["data"].arrayValue
                        
                        var i: Int
                        for (i = 0; i < followings.count; i++) {
                            let followingUN = followings[i]["username"].string
                            let followingFN = followings[i]["full_name"].string
                            followingsUsername.append(followingUN!)
                            followingsFullName.append(followingFN!)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        return (followingsUsername, followingsFullName)

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
