//
//  MenuViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/16/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Alamofire
import SwiftyJSON

class MenuViewController: UITabBarController {
    
    //STUFF FOR SET UP
    var shouldLogin = true
    var testing: Bool = true
    var mediaIDs: [String] = []
    var allLikes: [Int] = []
    var createdTimes: [String] = []
    var setUp: Bool = false
    
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
    
    var dates: [String] = []
    var totLikesPerHour: [String : [Int]] = [ : ]
    var aveLikesPerHour: [String: Double] = [ : ]
    var totLikesPerDay: [String : [Int]] = [ : ]
    var aveLikesPerDay: [String: Double] = [ : ]
    var totLikesPerMonth: [String : [Int]] = [ : ]
    var aveLikesPerMonth: [String: Double] = [ : ]
    var info = Info.sharedInstance
    var times: [Time] = []
    var days: [Day] = []
    var months: [Month] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = Realm()
        println("Menu View Did Load")
        
        if realm.objects(User).first != nil {
            //IF THERE IS A USER STORED IN REALM LOAD IT
            println("user found")
            self.user = realm.objects(User).first
            shouldLogin = false
        }
        
        println("should login: \(shouldLogin)")
        
        if shouldLogin {
            println("Logging In")
            performSegueWithIdentifier("Login", sender: self)
            shouldLogin = false
        } else {
            realm.write() {
                realm.objects(User).first!.set = false
                self.user?.set = false
            }
            if realm.objects(User).first != nil && realm.objects(User).first!.posts.description != user!.posts.description {
                println("RESET POSTS")
                self.mediaIDs = []
                self.allLikes = []
                self.createdTimes = []
                setUp = false
                realm.write() {
                    realm.objects(User).first!.set = false
                    self.user?.set = false
                }
            }
            println("set up: \(setUp)")
            if !setUp {
                let urlString = Instagram.Router.getRecent(user!.userID, user!.accessToken)
                getInfo(user!, request: urlString) {
                    NSLog("NUM OF POSTS \(self.user!.posts.count)")
                    self.optimizeAll()
                    self.setUp = true
                    realm.write() {
                        realm.objects(User).first!.set = true
                        self.user?.set = true
                    }
                }
                
            }
        }

        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu (segue : UIStoryboardSegue) {
        
    }
    
    
    
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
                    let realm = Realm()
                    realm.write() {
                        realm.objects(User).first!.posts.removeAll()
                    }

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
        for (i = 0; i < self.mediaIDs.count; i++) {
            //GOES THROUGH EACH POST
            let mediaID: String = self.mediaIDs[i]
            let likes: Int = self.allLikes[i]
            let createdTime: String = self.createdTimes[i]
            //let filter: String = self.filters[i]
            var newPost: Post = Post(id: mediaID, nol: likes, ct: createdTime)
            user.posts.append(newPost)
            let realm = Realm()
            realm.write(){
                realm.objects(User).first!.posts.append(newPost)
            }
            
        }
        
        callback()
    }
    

    //OPTIMIZE EVERYTHING
    func optimizeAll() {
        clearInfo()
        createDates()
        optimizeTime()
        optimizeDay()
    }
    
    func clearInfo() {
        dates = []
        info.times = []
        info.days = []
        info.months = []
        totLikesPerHour = [ : ]
        aveLikesPerHour = [ : ]
        for index in 0...23 {
            if (index < 10) {
                self.totLikesPerHour["0\(index)"] = []
            } else {
                self.totLikesPerHour["\(index)"] = []
            }
        }
        changeNanToZeroT()
        totLikesPerDay = [ : ]
        aveLikesPerDay = [ : ]
        info.days = []
        for index in 1...7 {
            totLikesPerDay["\(index)"] = []
        }
        changeNanToZeroD()
        totLikesPerMonth = [ : ]
        aveLikesPerMonth = [ : ]
        for index in 1...12 {
            if (index < 10) {
                totLikesPerMonth["0\(index)"] = []
            } else {
                totLikesPerMonth["\(index)"] = []
            }
        }
        changeNanToZeroM()
    }
    
    func createDates() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = post.getDate()
            dates.append(date.description)
        }
    }

    
    //OPTIMIZE TIMES
    func optimizeTime() {
        createHoursWithLikesT()
        createAveragesT()
        sortTimes()
        setBestTimeLabel()
    }
    
    func changeNanToZeroT() {
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
    
    func createHoursWithLikesT() {
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
    
    func createAveragesT() {
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
        var count: Int = 1
        
        for (i = 0; i < aveLikesPerHour.count; i++) {
            var likes: Double = averageLikesSorted[i]
            var ts = (aveLikesPerHour as NSDictionary).allKeysForObject(likes) as! [String]
            for t in ts {
                var timeName: String = getTimeName(t)
                var infoName: String = "average likes: \(((Double)( (Int)(likes * 100.0) ) ) / 100.0)"
                var rankName: String = "\(count)"
                info.times.append(Label(n: timeName, i: infoName, r: rankName))
                count++
            }
            i += ts.count - 1
        }
        
    }
    
    func getTimeName(timeNum: String) -> String {
        var timeName: String = ""
        
        if (timeNum == "00") {
            timeName = "12AM - 1AM"
        } else if (timeNum == "01") {
            timeName = "1AM - 2AM"
        } else if (timeNum == "02") {
            timeName = "2AM - 3AM"
        } else if (timeNum == "03") {
            timeName = "3AM - 4AM"
        } else if (timeNum == "04") {
            timeName = "4AM - 5AM"
        } else if (timeNum == "05") {
            timeName = "5AM - 6AM"
        } else if (timeNum == "06") {
            timeName = "6AM - 7AM"
        } else if (timeNum == "07") {
            timeName = "7AM - 8AM"
        } else if (timeNum == "08") {
            timeName = "8AM - 9AM"
        } else if (timeNum == "09") {
            timeName = "9AM - 10AM"
        } else if (timeNum == "10") {
            timeName = "10AM - 11AM"
        } else if (timeNum == "11") {
            timeName = "11AM - 12PM"
        } else if (timeNum == "12") {
            timeName = "12PM - 1PM"
        } else if (timeNum == "13") {
            timeName = "1PM - 2PM"
        } else if (timeNum == "14") {
            timeName = "2PM - 3PM"
        } else if (timeNum == "15") {
            timeName = "3PM - 4PM"
        } else if (timeNum == "16") {
            timeName = "4PM - 5PM"
        } else if (timeNum == "17") {
            timeName = "5PM - 6PM"
        } else if (timeNum == "18") {
            timeName = "6PM - 7PM"
        } else if (timeNum == "19") {
            timeName = "7PM - 8PM"
        } else if (timeNum == "20") {
            timeName = "8PM - 9PM"
        } else if (timeNum == "21") {
            timeName = "9PM - 10PM"
        } else if (timeNum == "22") {
            timeName = "10PM - 11PM"
        } else if (timeNum == "23") {
            timeName = "11PM - 12AM"
        }
        
        return timeName
    }
    
    func setBestTimeLabel() {
        //bestTimeLabel.text = info.times[0].timeName
    }
    
    
    //OPTIMIZE DAYS
    func optimizeDay() {
        createDaysWithLikes()
        createAveragesD()
        sortDays()
        setBestDayLabel()
    }
    
    func changeNanToZeroD() {
        for index in 1...7 {
            if (totLikesPerDay["\(index)"]! == []) {
                totLikesPerDay["\(index)"]!.append(0)
            }
        }
    }
    
    func createDaysWithLikes() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = dates[i]
            let rangeOfDate = Range(start: (advance(date.startIndex, 0)), end: (advance(date.startIndex, 10)))
            let dateString = date.substringWithRange(rangeOfDate)
            let dayOfWeek: Int = getDayOfWeek(dateString)
            let numOfLikes = post.numOfLikes
            totLikesPerDay["\(dayOfWeek)"]!.append(numOfLikes)
        }
    }
    
    func createAveragesD() {
        for i in 1...7 {
            let likes: [Int] = totLikesPerDay["\(i)"]!
            var sum: Int = 0
            var j: Int
            for (j = 0; j < likes.count; j++) {
                sum += likes[j]
            }
            let average: Double = Double(sum)/Double(likes.count)
            
            aveLikesPerDay["\(i)"] = average
            
        }
    }
    
    func sortDays() {
        var averageLikesSorted : [Double] = aveLikesPerDay.values.array
        averageLikesSorted.sort({ $0 > $1 })
        //quickSort(averageLikesSorted, start: 0, end: aveLikesPerHour.count)
        var i: Int
        var count: Int = 1
        println("SORTED DAYS")
        for (i = 0; i < aveLikesPerDay.count; i++) {
            var likes: Double = averageLikesSorted[i]
            var ds = (aveLikesPerDay as NSDictionary).allKeysForObject(likes) as! [String]
            for d in ds {
                var dayName: String = getDayName(d)
                var infoName: String = "average likes: \(((Double)( (Int)(likes * 100.0) ) ) / 100.0)"
                var rankName: String = "\(count)"
                info.days.append(Label(n: dayName, i: infoName, r: rankName))
                count++
            }
            i += ds.count - 1
        }
        
    }
    
    func getDayOfWeek(date:String) -> Int {
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(date)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.CalendarUnitWeekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
        
    }
    
    func getDayName(dayNum: String) -> String {
        var dayName: String = ""
        
        if (dayNum == "1") {
            dayName = "Sunday"
        } else if (dayNum == "2") {
            dayName = "Monday"
        } else if (dayNum == "3") {
            dayName = "Tuesday"
        } else if (dayNum == "4") {
            dayName = "Wednesday"
        } else if (dayNum == "5") {
            dayName = "Thursday"
        } else if (dayNum == "6") {
            dayName = "Friday"
        } else if (dayNum == "7") {
            dayName = "Saturday"
        }
        
        return dayName
    }
    
    func setBestDayLabel() {
        //bestDayLabel.text = info.days[0].dayName
    }
    
    
    //OPTIMIZE MONTHS
    func optimizeMonth() {
        createMonthsWithLikes()
        createAveragesM()
        sortMonths()
        setBestMonthLabel()
    }
    
    func changeNanToZeroM() {
        for index in 1...12 {
            if (index < 10) {
                if (totLikesPerMonth["0\(index)"]! == []) {
                    totLikesPerMonth["0\(index)"]!.append(0)
                }
            } else {
                if (totLikesPerMonth["\(index)"]! == []) {
                    totLikesPerMonth["\(index)"]!.append(0)
                }
            }
        }
    }
    
    func createMonthsWithLikes() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = dates[i]
            let rangeOfMonth = Range(start: (advance(date.startIndex, 5)), end: (advance(date.startIndex, 7)))
            let month = date.substringWithRange(rangeOfMonth)
            let numOfLikes = post.numOfLikes
            totLikesPerMonth[month]!.append(numOfLikes)
        }
    }
    
    func createAveragesM() {
        for i in 1...12 {
            let likes: [Int]
            if (i < 10) {
                likes = totLikesPerMonth["0\(i)"]!
            } else {
                likes = totLikesPerMonth["\(i)"]!
            }
            var sum: Int = 0
            var j: Int
            for (j = 0; j < likes.count; j++) {
                sum += likes[j]
            }
            let average: Double = Double(sum)/Double(likes.count)
            if (i < 10) {
                aveLikesPerMonth["0\(i)"] = average
            } else {
                aveLikesPerMonth["\(i)"] = average
            }
        }
    }
    
    func sortMonths() {
        var averageLikesSorted : [Double] = aveLikesPerMonth.values.array
        averageLikesSorted.sort({ $0 > $1 })
        
        println("SORTED MONTHS")
        var i: Int
        var count: Int = 1
        for (i = 0; i < aveLikesPerMonth.count; i++) {
            var likes: Double = averageLikesSorted[i]
            var ms = (aveLikesPerMonth as NSDictionary).allKeysForObject(likes) as! [String]
            for m in ms {
                var monthName: String = getMonthName(m)
                var infoName: String = "average likes: \(((Double)( (Int)(likes * 100.0) ) ) / 100.0)"
                var rankName: String = "\(count)"
                info.months.append(Label(n: monthName, i: infoName, r: rankName))
                count++
            }
            i += ms.count - 1
            
        }
        
    }
    
    func getMonthName(monthNum: String) -> String {
        var monthName: String = ""
        
        if (monthNum == "01") {
            monthName = "January"
        } else if (monthNum == "02") {
            monthName = "Febuary"
        } else if (monthNum == "03") {
            monthName = "March"
        } else if (monthNum == "04") {
            monthName = "April"
        } else if (monthNum == "05") {
            monthName = "May"
        } else if (monthNum == "06") {
            monthName = "June"
        } else if (monthNum == "07") {
            monthName = "July"
        } else if (monthNum == "08") {
            monthName = "August"
        } else if (monthNum == "09") {
            monthName = "September"
        } else if (monthNum == "10") {
            monthName = "October"
        } else if (monthNum == "11") {
            monthName = "November"
        } else if (monthNum == "12") {
            monthName = "December"
        }
        
        return monthName
    }
    
    func setBestMonthLabel() {
        //bestMonthLabel.text = info.months[0].monthName
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        println("Button Tapped")
        var tabBarController = self
        tabBarController.selectedIndex = 0
    }


}
