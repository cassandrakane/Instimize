//
//  MonthViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/13/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class MonthViewController: UITabBarController {

    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    var user: User = User()
    var dates: [String] = []
    var totLikesPerMonth: [String : [Int]] = [ : ]
    var aveLikesPerMonth: [String: Double] = [ : ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUser()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        optimizeMonth()
        println("Date Opted")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUser() {
        let realm = Realm()
        user = realm.objects(User).first!
    }
    
    
    func optimizeMonth() {
        dates = []
        totLikesPerMonth = [ : ]
        aveLikesPerMonth = [ : ]
        for index in 1...12 {
            if (index < 10) {
                totLikesPerMonth["0\(index)"] = []
            } else {
                totLikesPerMonth["\(index)"] = []
            }
        }
        createDates()
        changeNanToZero()
        createMonthsWithLikes()
        createAverages()
        sortMonths()
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
        for (i = 0; i < user.posts.count; i++) {
            let post = user.posts[i]
            let date = dates[i]
            let rangeOfMonth = Range(start: (advance(date.startIndex, 5)), end: (advance(date.startIndex, 7)))
            let month = date.substringWithRange(rangeOfMonth)
            let numOfLikes = post.numOfLikes
            totLikesPerMonth[month]!.append(numOfLikes)
        }
    }
    
    func createAverages() {
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
        for (i = 0; i < aveLikesPerMonth.count; i++) {
            var likes: Double = averageLikesSorted[i]
            var months = (aveLikesPerMonth as NSDictionary).allKeysForObject(likes) as! [String]
            for month in months {
                println("MONTH: \(month) - AVERAGE LIKES: \(likes)")
            }
            i += months.count - 1
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
