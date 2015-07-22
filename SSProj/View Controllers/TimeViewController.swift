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
