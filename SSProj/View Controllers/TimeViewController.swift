//
//  TimeViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/13/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Foundation
import LBBlurredImage


class TimeViewController: UIViewController {

    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    
    @IBOutlet weak var bestTimeLabel: UILabel!
    
    
    //STUFF FOR TIME OPT
    var user: User = User()
    /*
    var dates: [String] = []
    var totLikesPerHour: [String : [Int]] = [ : ]
    var aveLikesPerHour: [String: Double] = [ : ]
    */
    var info = Info.sharedInstance
    var times: [Time] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        println("Time Did Load")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        println("Time View Did Appear")
        super.viewDidAppear(animated)
        
        let realm = Realm()
        if realm.objects(User).first != nil {
            setUser()
            //bestTimeLabel.text = ""
            if user.set {
                times = info.times
                
                var background: UIImage = UIImage(named: "TestTest")!
                self.blurredImageView.setImageToBlur(background, blurRadius: 10, completionBlock: nil)
                self.tableView.tableHeaderView = tableHeaderView
            
                //optimizeTime()
                
                self.tableView.dataSource = self
                self.tableView.delegate = self
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUser() {
        println("setting user")
        let realm = Realm()
        user = realm.objects(User).first!
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    /*
    //TIME OPTIMIZATION
    func optimizeTime() {
        dates = []
        totLikesPerHour = [ : ]
        aveLikesPerHour = [ : ]
        info.times = []
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
    
    func createDatesT() {
        var i: Int = 0
        for (i = 0; i < user.posts.count; i++) {
            let post = user.posts[i]
            let date = post.getDate()
            dates.append(date.description)
        }
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
        for (i = 0; i < user.posts.count; i++) {
            let post = user.posts[i]
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
                info.times.append(Time(t: timeName, i: infoName, r: rankName))
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

extension TimeViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(times.count)
        return Int(times.count ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TimeTableViewCell
        
        let row = indexPath.row
        let time = times[row] as Time
        cell.time = time
        
        
        return cell
    }
}

extension TimeViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
}

extension TimeViewController: UIScrollViewDelegate {
    
}
