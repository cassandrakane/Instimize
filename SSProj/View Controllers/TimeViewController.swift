//
//  TimeViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/13/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Alamofire
import SwiftyJSON

class TimeViewController: UIViewController {
    
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    //STUFF FOR SET UP
    var shouldLogin = true
    var testing: Bool = true
    var mediaIDs: [String] = []
    var allLikes: [Int] = []
    var createdTimes: [String] = []
    
    //STUFF FOR TIME OPT
    var dates: [String] = []
    var totLikesPerHour: [String : [Int]] = [ : ]
    var aveLikesPerHour: [String: Double] = [ : ]
    
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
            for index in 0...23 {
                if (index < 10) {
                    totLikesPerHour["0\(index)"] = []
                } else {
                    totLikesPerHour["\(index)"] = []
                }
            }
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
                
                //TIME OPT STUFF
                self.createDates()
                self.createHoursWithLikes()
                self.createAverages()
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
    

    //TIME OPTI
    func createDates() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = post.getDate()
            dates.append(date.description)
        }
    }
    
    func createHoursWithLikes() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = dates[i]
            let rangeOfMonth = Range(start: (advance(date.startIndex, 11)), end: (advance(date.startIndex, 13)))
            let month = date.substringWithRange(rangeOfMonth)
            let numOfLikes = post.numOfLikes
            totLikesPerHour[month]!.append(numOfLikes)
        }
    }
    
    func createAverages() {
        for i in 0...23 {
            let likes: [Int]
            if (i < 10) {
                likes = totLikesPerHour["0\(i)"]!
            } else {
                likes = totLikesPerHour["\(i)"]!
            }
            var sum: Int = 0
            var j: Int
            for (j = 0; j < likes.count; j++) {
                sum += likes[j]
            }
            let average: Double = Double(sum)/Double(likes.count)
            if (i < 10) {
                aveLikesPerHour["0\(i)"] = average
            } else {
                aveLikesPerHour["\(i)"] = average
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
