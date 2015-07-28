//
//  RootViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/22/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Alamofire
import SwiftyJSON

class RootViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController = UIPageViewController()
    var pageDataTypes: NSArray = []
    var pageImages: NSArray = []
    var pageDataTypeLabels: NSArray = []
    var pageBestDataLabels: NSArray = []
    var bestTime: String = ""
    var bestDay: String = ""
    var bestMonth: String = ""
    var timeImage: String = ""
    var seasonImage: String = ""
    
    //STUFF FOR SET UP
    var shouldLogin = true
    //var newLogin = false
    var testing: Bool = true
    var mediaIDs: [String] = []
    var allLikes: [Int] = []
    var createdTimes: [String] = []
    
    var user: User? {
        didSet {
            if user != nil {
                println("user isn't nil")
            } else {
                println("user is nil")
                shouldLogin = true
            }
        }
    }
    
    var timeZone: NSTimeZone = NSTimeZone.localTimeZone()
    var dates: [String] = []
    var totLikesPerHour: [String : [Int]] = [ : ]
    var aveLikesPerHour: [String: Double] = [ : ]
    var totLikesPerDay: [String : [Int]] = [ : ]
    var aveLikesPerDay: [String: Double] = [ : ]
    var totLikesPerMonth: [String : [Int]] = [ : ]
    var aveLikesPerMonth: [String: Double] = [ : ]
    var info = Info.sharedInstance
    var times: [Label] = []
    var days: [Label] = []
    var months: [Label] = []
    
    @IBAction func unwindToMenu (segue : UIStoryboardSegue) {
        info.newLogin = true
    }
    
    override func viewDidLoad() {
        println("ROOT VIEW DID LOAD")
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
        setUpUser() {
            self.pageImages = [self.timeImage, "TestTest", self.seasonImage]
            self.pageDataTypes = ["Time", "Day", "Month"]
            self.pageDataTypeLabels = ["Best Time Of Day", "Best Day Of Week", "Best Month Of Year"]
            self.pageBestDataLabels = [self.bestTime, self.bestDay, self.bestMonth]
            
            // Create page view controller
            self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
            self.pageViewController.dataSource = self
            var startingViewController: PageContentViewController = self.viewControllerAtIndex(0)
            var viewControllers: NSArray = [startingViewController]
            self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            
            
            // Change the size of page view controller
            self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 40);
            self.addChildViewController(self.pageViewController)
            self.view.addSubview(self.pageViewController.view)
            self.pageViewController.didMoveToParentViewController(self)
        
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        println("ROot View DID Appear")
        super.viewDidAppear(true)
        self.navigationController?.navigationBarHidden = true
        if info.newLogin {
            setUpUser() {
                println("setting up user")
                self.pageImages = [self.timeImage, "TestTest", self.seasonImage]
                self.pageDataTypes = ["Time", "Day", "Month"]
                self.pageDataTypeLabels = ["Best Time Of Day", "Best Day Of Week", "Best Month Of Year"]
                self.pageBestDataLabels = [self.bestTime, self.bestDay, self.bestMonth]
                
                // Create page view controller
                self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
                self.pageViewController.dataSource = self
                var startingViewController: PageContentViewController = self.viewControllerAtIndex(0)
                var viewControllers: NSArray = [startingViewController]
                self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
                
                
                // Change the size of page view controller
                self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 40);
                self.addChildViewController(self.pageViewController)
                self.view.addSubview(self.pageViewController.view)
                self.pageViewController.didMoveToParentViewController(self)
                
            }
        }
        info.newLogin = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpUser(callback: () -> Void) {
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
                info.setUp = false
            }
            println("set up: \(info.setUp)")
            if !info.setUp {
                println("RESET POSTS")
                self.mediaIDs = []
                self.allLikes = []
                self.createdTimes = []
                realm.write() {
                    realm.objects(User).first!.set = false
                    self.user?.set = false
                }
                let urlString = Instagram.Router.getRecent(user!.userID, user!.accessToken)
                getInfo(user!, request: urlString) {
                    NSLog("NUM OF POSTS \(self.user!.posts.count)")
                    self.optimizeAll()
                    self.info.setUp = true
                    realm.write() {
                        realm.objects(User).first!.set = true
                        self.user?.set = true
                    }
                    callback()
                }
            } else {
                callback()
            }
        }
        //callback()
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
        optimizeMonth()
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
        totLikesPerDay = [ : ]
        aveLikesPerDay = [ : ]
        info.days = []
        for index in 1...7 {
            totLikesPerDay["\(index)"] = []
        }
        totLikesPerMonth = [ : ]
        aveLikesPerMonth = [ : ]
        for index in 1...12 {
            if (index < 10) {
                totLikesPerMonth["0\(index)"] = []
            } else {
                totLikesPerMonth["\(index)"] = []
            }
        }
    }
    
    func createDates() {
        var i: Int = 0
        for (i = 0; i < user!.posts.count; i++) {
            let post = user!.posts[i]
            let date = post.getDate()
            dates.append(date)
        }
    }
    
    
    //OPTIMIZE TIMES
    func optimizeTime() {
        createHoursWithLikesT()
        changeNanToZegativeT()
        createAveragesT()
        sortTimes()
    }
    
    func changeNanToZegativeT() {
        for index in 0...23 {
            if (index < 10) {
                if (totLikesPerHour["0\(index)"]! == []) {
                    totLikesPerHour["0\(index)"]!.append(-1)
                }
            } else {
                if (totLikesPerHour["\(index)"]! == []) {
                    totLikesPerHour["\(index)"]!.append(-1)
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
                var (timeName, timePhoto) : (String, String) = getTimeName(t)
                var likesName: String = ""
                var postName: String = ""
                if (likes >= 0) {
                    likesName = "average likes: \(((Double)( (Int)(likes * 100.0) ) ) / 100.0)"
                    postName = "# of posts: \(totLikesPerHour[t]!.count)"
                } else {
                    likesName = "average likes: n/a"
                    postName = "# of posts: 0"
                }

                var rankName: String = "\(count)"
                info.times.append(Label(n: timeName, l: likesName, p: postName, r: rankName, ph: timePhoto))
                count++
            }
            i += ts.count - 1
        }
        
        bestTime = info.times[0].name
        if (bestTime == "6AM – 7AM" || bestTime == "7AM – 8AM" || bestTime == "8AM – 9AM" || bestTime == "9AM – 10AM" || bestTime == "10AM – 11AM" || bestTime == "11AM – 12PM" || bestTime == "12PM – 1PM" || bestTime == "1PM – 2PM" || bestTime == "2PM – 3PM" || bestTime == "3PM – 4PM" || bestTime == "4PM – 5PM" || bestTime == "5PM – 6PM") {
            timeImage = "Day"
        } else if (bestTime == "6PM – 7PM" || bestTime == "7PM – 8PM" || bestTime == "8PM – 9PM" || bestTime == "9PM – 10PM" || bestTime == "10PM – 11PM" || bestTime == "11PM – 12AM" || bestTime == "12AM – 1AM" || bestTime == "1AM – 2AM" || bestTime == "2AM – 3AM" || bestTime == "3AM – 4AM" || bestTime == "4AM – 5AM" || bestTime == "5AM – 6AM") {
            timeImage = "Night"
        } else {
            timeImage = "TestTest"
        }
        
    }
    
    func getTimeName(timeNum: String) -> (String, String) {
        var timeName: String = ""
        var timePhoto: String = ""
        
        if (timeNum == "00") {
            timeName = "12AM – 1AM"
            timePhoto = "12"
        } else if (timeNum == "01") {
            timeName = "1AM – 2AM"
            timePhoto = "1"
        } else if (timeNum == "02") {
            timeName = "2AM – 3AM"
            timePhoto = "2"
        } else if (timeNum == "03") {
            timeName = "3AM – 4AM"
            timePhoto = "3"
        } else if (timeNum == "04") {
            timeName = "4AM – 5AM"
            timePhoto = "4"
        } else if (timeNum == "05") {
            timeName = "5AM – 6AM"
            timePhoto = "5"
        } else if (timeNum == "06") {
            timeName = "6AM – 7AM"
            timePhoto = "6"
        } else if (timeNum == "07") {
            timeName = "7AM – 8AM"
            timePhoto = "7"
        } else if (timeNum == "08") {
            timeName = "8AM – 9AM"
            timePhoto = "8"
        } else if (timeNum == "09") {
            timeName = "9AM – 10AM"
            timePhoto = "9"
        } else if (timeNum == "10") {
            timeName = "10AM – 11AM"
            timePhoto = "10"
        } else if (timeNum == "11") {
            timeName = "11AM – 12PM"
            timePhoto = "11"
        } else if (timeNum == "12") {
            timeName = "12PM – 1PM"
            timePhoto = "12"
        } else if (timeNum == "13") {
            timeName = "1PM – 2PM"
            timePhoto = "1"
        } else if (timeNum == "14") {
            timeName = "2PM – 3PM"
            timePhoto = "2"
        } else if (timeNum == "15") {
            timeName = "3PM – 4PM"
            timePhoto = "3"
        } else if (timeNum == "16") {
            timeName = "4PM – 5PM"
            timePhoto = "4"
        } else if (timeNum == "17") {
            timeName = "5PM – 6PM"
            timePhoto = "5"
        } else if (timeNum == "18") {
            timeName = "6PM – 7PM"
            timePhoto = "6"
        } else if (timeNum == "19") {
            timeName = "7PM – 8PM"
            timePhoto = "7"
        } else if (timeNum == "20") {
            timeName = "8PM – 9PM"
            timePhoto = "8"
        } else if (timeNum == "21") {
            timeName = "9PM – 10PM"
            timePhoto = "9"
        } else if (timeNum == "22") {
            timeName = "10PM – 11PM"
            timePhoto = "10"
        } else if (timeNum == "23") {
            timeName = "11PM – 12AM"
            timePhoto = "11"
        }
        
        return (timeName, timePhoto)
    }
    
    
    //OPTIMIZE DAYS
    func optimizeDay() {
        createDaysWithLikes()
        changeNanToZegativeD()
        createAveragesD()
        sortDays()
    }
    
    func changeNanToZegativeD() {
        for index in 1...7 {
            if (totLikesPerDay["\(index)"]! == []) {
                totLikesPerDay["\(index)"]!.append(-1)
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
                var (dayName, dayPhoto): (String, String) = getDayName(d)
                var likesName: String = ""
                var postName: String = ""
                if (likes >= 0) {
                    likesName = "average likes: \(((Double)( (Int)(likes * 100.0) ) ) / 100.0)"
                    postName = "# of posts: \(totLikesPerDay[d]!.count)"
                } else {
                    likesName = "average likes: n/a"
                    postName = "# of posts: 0"
                }
                var rankName: String = "\(count)"
                info.days.append(Label(n: dayName, l: likesName, p: postName, r: rankName, ph: dayPhoto))
                count++
            }
            i += ds.count - 1
        }
        
        bestDay = info.days[0].name
        
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
    
    func getDayName(dayNum: String) -> (String, String) {
        var dayName: String = ""
        var dayPhoto: String = ""
        
        if (dayNum == "1") {
            dayName = "Sunday"
            dayPhoto = "Sunday"
        } else if (dayNum == "2") {
            dayName = "Monday"
            dayPhoto = "Monday"
        } else if (dayNum == "3") {
            dayName = "Tuesday"
            dayPhoto = "Tuesday"
        } else if (dayNum == "4") {
            dayName = "Wednesday"
            dayPhoto = "Wednesday"
        } else if (dayNum == "5") {
            dayName = "Thursday"
            dayPhoto = "Thursday"
        } else if (dayNum == "6") {
            dayName = "Friday"
            dayPhoto = "Friday"
        } else if (dayNum == "7") {
            dayName = "Saturday"
            dayPhoto = "Saturday"
        }
        
        return (dayName, dayPhoto)
    }
    
    
    //OPTIMIZE MONTHS
    func optimizeMonth() {
        createMonthsWithLikes()
        changeNanToZegativeM()
        createAveragesM()
        sortMonths()
    }
    
    func changeNanToZegativeM() {
        for index in 1...12 {
            if (index < 10) {
                if (totLikesPerMonth["0\(index)"]! == []) {
                    totLikesPerMonth["0\(index)"]!.append(-1)
                }
            } else {
                if (totLikesPerMonth["\(index)"]! == []) {
                    totLikesPerMonth["\(index)"]!.append(-1)
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
                var (monthName, monthPhoto): (String, String) = getMonthName(m)
                var likesName: String = ""
                var postName: String = ""
                if (likes >= 0) {
                    likesName = "average likes: \(((Double)( (Int)(likes * 100.0) ) ) / 100.0)"
                    postName = "# of posts: \(totLikesPerMonth[m]!.count)"
                } else {
                    likesName = "average likes: n/a"
                    postName = "# of posts: 0"
                }
                var rankName: String = "\(count)"
                info.months.append(Label(n: monthName, l: likesName, p: postName, r: rankName, ph: monthPhoto))
                count++
            }
            i += ms.count - 1
            
        }
        
        bestMonth = info.months[0].name
        if (bestMonth == "December" || bestMonth == "January" || bestMonth == "February") {
            seasonImage = "Winter"
        } else if (bestMonth == "March" || bestMonth == "April" || bestMonth == "May") {
            seasonImage = "Spring"
        } else if (bestMonth == "June" || bestMonth == "July" || bestMonth == "August") {
            seasonImage = "Summer"
        } else if (bestMonth == "September" || bestMonth == "October" || bestMonth == "November") {
            seasonImage = "Autumn"
        } else {
            seasonImage = "TestTest"
        }
        
    }
    
    func getMonthName(monthNum: String) -> (String, String) {
        var monthName: String = ""
        var monthPhoto: String = ""
        
        if (monthNum == "01") {
            monthName = "January"
            monthPhoto = "January"
        } else if (monthNum == "02") {
            monthName = "February"
            monthPhoto = "February"
        } else if (monthNum == "03") {
            monthName = "March"
            monthPhoto = "March"
        } else if (monthNum == "04") {
            monthName = "April"
            monthPhoto = "April"
        } else if (monthNum == "05") {
            monthName = "May"
            monthPhoto = "May"
        } else if (monthNum == "06") {
            monthName = "June"
            monthPhoto = "June"
        } else if (monthNum == "07") {
            monthName = "July"
            monthPhoto = "July"
        } else if (monthNum == "08") {
            monthName = "August"
            monthPhoto = "August"
        } else if (monthNum == "09") {
            monthName = "September"
            monthPhoto = "September"
        } else if (monthNum == "10") {
            monthName = "October"
            monthPhoto = "October"
        } else if (monthNum == "11") {
            monthName = "November"
            monthPhoto = "November"
        } else if (monthNum == "12") {
            monthName = "December"
            monthPhoto = "December"
        }
        
        return (monthName, monthPhoto)
    }
    
    

    func viewControllerAtIndex(index: NSInteger) -> PageContentViewController {
        if ((self.pageImages.count == 0) || (index >= self.pageImages.count)) {
            return PageContentViewController()
        }
        // Create a new view controller and pass suitable data.
        var pageContentViewController: PageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageContentViewController") as! PageContentViewController
        pageContentViewController.imageFile = self.pageImages[index] as! String
        pageContentViewController.dataType = self.pageDataTypes[index] as! String
        pageContentViewController.dataTypeString = self.pageDataTypeLabels[index] as! String
        pageContentViewController.bestDataString = self.pageBestDataLabels[index] as! String
        pageContentViewController.pageIndex = index
        
        return pageContentViewController;

    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> NSInteger {
        return self.pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> NSInteger {
        return 0
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

extension RootViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index: NSInteger = (viewController as! PageContentViewController).pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil;
        }
        
        index--;
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
         var index: NSInteger = (viewController as! PageContentViewController).pageIndex
        
        if (index == NSNotFound) {
            return nil;
        }
        
        index++;
        if index == self.pageImages.count {
            return nil;
        }
        return viewControllerAtIndex(index);
    }
    
}

