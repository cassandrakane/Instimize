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
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bestTimeLabel: UILabel!
    
    //STUFF FOR SET UP
    var shouldLogin = true
    var testing: Bool = true
    var mediaIDs: [String] = []
    var allLikes: [Int] = []
    var createdTimes: [String] = []
    var setUp: Bool = false
    
    //STUFF FOR TIME OPT
    var dates: [String] = []
    var totLikesPerHour: [String : [Int]] = [ : ]
    var aveLikesPerHour: [String: Double] = [ : ]
    var times: [Time] = []
    
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
        println("Time View Did Load")
        
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
        println("Time View Did Appear")
        super.viewDidAppear(animated)
        println(shouldLogin)
        
        if shouldLogin {
            println("Logging In")
            performSegueWithIdentifier("Login", sender: self)
            shouldLogin = false
        } else {
            let realm = Realm()
            if realm.objects(User).first != nil && realm.objects(User).first!.posts.description != user!.posts.description {
                println("RESET POSTS")
                self.mediaIDs = []
                self.allLikes = []
                self.createdTimes = []
                setUp = false
            }
            if setUp {
                self.optimizeTime()
                println("Time Opted")
                self.setLabels()
            } else {
                let urlString = Instagram.Router.getRecent(user!.userID, user!.accessToken)
                getInfo(user!, request: urlString) {
                    NSLog("NUM OF POSTS \(self.user!.posts.count)")
                    self.setUp = true
                    //TIME OPT STUFF
                    self.optimizeTime()
                    println("Time Opted")
                    self.setLabels()
                }

            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToMenu (segue : UIStoryboardSegue) {
        
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
    func optimizeTime() {
        dates = []
        totLikesPerHour = [ : ]
        aveLikesPerHour = [ : ]
        times = []
        for index in 0...23 {
            if (index < 10) {
                self.totLikesPerHour["0\(index)"] = []
            } else {
                self.totLikesPerHour["\(index)"] = []
            }
        }
        self.createDates()
        self.changeNanToZero()
        self.createHoursWithLikes()
        self.createAverages()
        self.sortTimes()
    }
    
    func createDates() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = post.getDate()
            dates.append(date.description)
        }
    }
    
    func changeNanToZero() {
        for index in 0...23 {
            if (index < 10) {
                if (totLikesPerHour["0\(index)"]! == []) {
                    totLikesPerHour["0\(index)"]!.append(0)
                }
            } else {
                if (totLikesPerHour["\(index)"]! == []) {
                    totLikesPerHour["\(index)"]!.append(0)
                }
            }
        }
    }
    
    func createHoursWithLikes() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = dates[i]
            let rangeOfHour = Range(start: (advance(date.startIndex, 11)), end: (advance(date.startIndex, 13)))
            let hour = date.substringWithRange(rangeOfHour)
            let numOfLikes = post.numOfLikes
            totLikesPerHour[hour]!.append(numOfLikes)
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
    
    func sortTimes() {
        var averageLikesSorted : [Double] = aveLikesPerHour.values.array
        averageLikesSorted.sort({ $0 > $1 })
        
        println("SORTED TIMES")
        var i: Int
        for (i = 0; i < aveLikesPerHour.count; i++) {
            var likes: Double = averageLikesSorted[i]
            var ts = (aveLikesPerHour as NSDictionary).allKeysForObject(likes) as! [String]
            for t in ts {
                var timeName: String = getTimeName(t)
                var likesName: String = "\(likes)"
                times.append(Time(t: timeName, l: likesName))
            }
            i += ts.count - 1
        }
    
    }
    
    func getTimeName(timeNum: String) -> String {
        var timeName: String = ""
        
        if (timeNum == "00") {
            timeName = "12AM to 1AM"
        } else if (timeNum == "01") {
            timeName = "1AM to 2AM"
        } else if (timeNum == "02") {
            timeName = "2AM to 3AM"
        } else if (timeNum == "03") {
            timeName = "3AM to 4AM"
        } else if (timeNum == "04") {
            timeName = "4AM to 5AM"
        } else if (timeNum == "05") {
            timeName = "5AM to 6AM"
        } else if (timeNum == "06") {
            timeName = "6AM to 7AM"
        } else if (timeNum == "07") {
            timeName = "7AM to 8AM"
        } else if (timeNum == "08") {
            timeName = "8AM to 9AM"
        } else if (timeNum == "09") {
            timeName = "9AM to 10AM"
        } else if (timeNum == "10") {
            timeName = "10AM to 11AM"
        } else if (timeNum == "11") {
            timeName = "11AM to 12PM"
        } else if (timeNum == "12") {
            timeName = "12PM to 1PM"
        } else if (timeNum == "13") {
            timeName = "1PM to 2PM"
        } else if (timeNum == "14") {
            timeName = "2PM to 3PM"
        } else if (timeNum == "15") {
            timeName = "3PM to 4PM"
        } else if (timeNum == "16") {
            timeName = "4PM to 5PM"
        } else if (timeNum == "17") {
            timeName = "5PM to 6PM"
        } else if (timeNum == "18") {
            timeName = "6PM to 7PM"
        } else if (timeNum == "19") {
            timeName = "7PM to 8PM"
        } else if (timeNum == "20") {
            timeName = "8PM to 9PM"
        } else if (timeNum == "21") {
            timeName = "9PM to 10PM"
        } else if (timeNum == "22") {
            timeName = "10PM to 11PM"
        } else if (timeNum == "23") {
            timeName = "11PM to 12AM"
        }
        
        return timeName
    }
    
    func setLabels() {
        fullNameLabel.text = "FULL NAME"
        usernameLabel.text = "username"
        bestTimeLabel.text = times[0].timeName
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
