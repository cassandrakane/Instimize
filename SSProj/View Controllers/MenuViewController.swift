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
    
    /*
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    var shouldLogin = true
    var testing: Bool = true
    var mediaIDs: [String] = []
    var allLikes: [Int] = []
    var createdTimes: [String] = []

    var user: User? {
        didSet {
            if user != nil {
                //hideLogoutButtonItem(false)
                println("user isn't nil")
            } else {
                println("user is nil")
                shouldLogin = true
                
                //hideLogoutButtonItem(true)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = Realm()
        println("View Did Load")
        if realm.objects(User).first != nil {
            //IF THERE IS A USER STORED IN REALM LOAD IT
            println("user found")
            self.user = realm.objects(User).first
            shouldLogin = false
        }
        
        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(animated: Bool) {
        println("View Did Appear")
        super.viewDidAppear(animated)
        println(shouldLogin)
        if shouldLogin {
            println("Logging In")
            performSegueWithIdentifier("Login", sender: self)
            shouldLogin = false
        } else {
            let urlString = Instagram.Router.getRecent(user!.userID, user!.accessToken)
            getInfo(user!, request: urlString) {
                NSLog("NUM OF POSTS \(self.user!.posts.count)")
            }
        }
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

    
    //ACCESSING AND CREATING INFORMATION
    
    func getInfo(user: User, request: URLRequestConvertible, callback: () -> Void) {
        //GETS INFO FROM INSTAGRAM
        
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                
                let json = JSON(jsonObject!)
                if (json["meta"]["code"].intValue  == 200) {
                    
                    //GET ALL MEDIA IDS
                
                    //clear out previous posts
                    user.posts = List<Post> ()
                    
                    
                    let posts = json["data"].arrayValue
                    
                    var i: Int
                    for (i = 0; i < posts.count; i++) {
                        let mediaID = posts[i]["id"].string!
                        let likes = String(stringInterpolationSegment: posts[i]["likes"]["count"]).toInt()!
                        let createdTime = posts[i]["created_time"].string!
                        //let filter = posts[i]["filter"].string!
                        self.mediaIDs.append(mediaID)
                        self.allLikes.append(likes)
                        self.createdTimes.append(createdTime)
                        //self.filters.append(filter)
                    }
                    
                    if let urlString = json["pagination"]["next_url"].URL {
                        var nextURLRequest = NSURLRequest(URL: urlString)
                        self.getInfo(user, request: nextURLRequest) {
                            callback()
                        }
                    } else {
                        self.makeAllPosts(user) {
                            callback()
                        }
                    }
                }
            }
        }
    }
    
    func makeAllPosts(user: User, callback: () -> Void) {
        //GETS ALL LIKES/COMMENTS
        var i: Int
        let realm = Realm()
        //clear posts
        realm.write() {
            realm.objects(User).first!.posts.removeAll()
        }
        for (i = 0; i < self.mediaIDs.count; i++) {
            //GOES THROUGH EACH POST
            let mediaID: String = self.mediaIDs[i]
            let likes: Int = self.allLikes[i]
            let createdTime: String = self.createdTimes[i]
            //let filter: String = self.filters[i]
            var newPost: Post = Post(id: mediaID, nol: likes, ct: createdTime)
            user.posts.append(newPost)
            realm.write(){
                realm.objects(User).first!.posts.append(newPost)
            }
         
        }
        
        callback()
    }
    
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}