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

class MonthViewController: UIViewController {

    @IBOutlet weak var bestMonthLabel: UILabel!
    
    var user: User = User()
    var dates: [String] = []
    var totLikesPerMonth: [String : [Int]] = [ : ]
    var aveLikesPerMonth: [String: Double] = [ : ]
    var info = Info.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bestMonthLabel.text = ""
        
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
        info.months = []
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
        setBestMonthLabel()
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
            var ms = (aveLikesPerMonth as NSDictionary).allKeysForObject(likes) as! [String]
            for m in ms {
                var monthName: String = getMonthName(m)
                var likesName: String = "\(likes)"
                info.months.append(Month(m: monthName, l: likesName))
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
        bestMonthLabel.text = info.months[0].monthName
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
