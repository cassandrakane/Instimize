//
//  DayViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/13/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class DayViewController: UITabBarController {

    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    var user: User = User()
    var dates: [String] = []
    var totLikesPerDay: [String : [Int]] = [ : ]
    var aveLikesPerDay: [String: Double] = [ : ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUser()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        optimizeDay()
        println("Day Opted")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUser() {
        let realm = Realm()
        user = realm.objects(User).first!
    }
    
    
    func optimizeDay() {
        dates = []
        totLikesPerDay = [ : ]
        aveLikesPerDay = [ : ]
        for index in 1...7 {
            totLikesPerDay["\(index)"] = []
        }
        createDates()
        changeNanToZero()
        createDaysWithLikes()
        createAverages()
        sortDays()
    }
    
    func createDates() {
        var i: Int = 0
        for (i = 0; i < user.posts.count; i++) {
            let post = user.posts[i]
            let date = post.getDate()
            dates.append(date.description)
        }
    }
    
    func changeNanToZero() {
        for index in 1...7 {
            if (totLikesPerDay["\(index)"]! == []) {
                totLikesPerDay["\(index)"]!.append(0)
            }
        }
    }
    
    func createDaysWithLikes() {
        var i: Int = 0
        for (i = 0; i < user.posts.count; i++) {
            let post = user.posts[i]
            let date = dates[i]
            let rangeOfDate = Range(start: (advance(date.startIndex, 0)), end: (advance(date.startIndex, 10)))
            let dateString = date.substringWithRange(rangeOfDate)
            let dayOfWeek: Int = getDayOfWeek(dateString)
            let numOfLikes = post.numOfLikes
            totLikesPerDay["\(dayOfWeek)"]!.append(numOfLikes)
        }
    }
    
    func createAverages() {
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
        println("SORTED DAYS")
        for (i = 0; i < aveLikesPerDay.count; i++) {
            var likes: Double = averageLikesSorted[i]
            var days = (aveLikesPerDay as NSDictionary).allKeysForObject(likes) as! [String]
            for day in days {
                println("DAY: \(day) - AVERAGE LIKES: \(likes)")
            }
            i += days.count - 1
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
