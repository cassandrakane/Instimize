//
//  PageContentViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/22/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Foundation
import LBBlurredImage

class PageContentViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var pageIndex: Int = 0
    var imageFile: String = ""
    var user: User = User()
   
    var info = Info.sharedInstance
    var times: [Time] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame: CGRect = UIScreen.mainScreen().bounds
        self.backgroundImage.image = UIImage(named: imageFile)
        tableView.tableHeaderView = headerView
      
        
        let realm = Realm()
        if realm.objects(User).first != nil {
            setUser()
            //bestTimeLabel.text = ""
            if user.set {
                //times = info.times
                times = [Time(t: "Test1", i: "test1", r: "#"), Time(t: "Test2", i: "test2", r: "#"), Time(t: "Test3", i: "test3", r: "#")]
                //tableView.dataSource = self
                //tableView.delegate = self
            }
        }

        
        
        // Do any additional setup after loading the view.
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PageContentViewController: UITableViewDataSource {
    
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

extension PageContentViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
}

extension TimeViewController: UIScrollViewDelegate {
    
}

