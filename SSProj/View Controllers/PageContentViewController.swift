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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bestDataTypeLabel: UILabel!
    @IBOutlet weak var bestDataLabel: UILabel!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    var settingsOpen = false
    
    var pageIndex: Int = 0
    var dataType: String = ""
    var imageFile: String = ""
    var dataTypeString: String = ""
    var bestDataString: String = ""
    var user: User = User()
    var info = Info.sharedInstance
    var data : [Label] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("page content vc did load")
        
        tableView.tableHeaderView!.bounds.size.height = UIScreen.mainScreen().bounds.size.height + 90
        self.backgroundImage.image = UIImage(named: imageFile)
        
        bestDataTypeLabel.text = dataTypeString
        bestDataLabel.text = bestDataString
        
        self.settingsView.bounds.size.width = UIScreen.mainScreen().bounds.size.width - 100
        self.settingsView.bounds.size.height = UIScreen.mainScreen().bounds.size.width - 100

        
        let realm = Realm()
        if realm.objects(User).first != nil {
            setUser()
            if user.set {
                if (dataType == "Time") {
                    data = info.times
                } else if (dataType == "Day") {
                    data = info.days
                } else if (dataType == "Month") {
                    data = info.months
                } else {
                    data = [Label(n: "Error", l: "error", p: "error", r: "#", ph: "Test Image")]
                }
            }
        }
        self.view.bounds = UIScreen.mainScreen().bounds
        println("viewDidLoad imageView Frame : \(backgroundImage.frame) pageIndex : \(pageIndex)")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.view.bounds = UIScreen.mainScreen().bounds
        println("viewWillAppear imageView Frame : \(backgroundImage.frame) pageIndex : \(pageIndex)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bounds = UIScreen.mainScreen().bounds
        println("viewDidAppear imageView Frame : \(backgroundImage.frame) pageIndex : \(pageIndex)")
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    
    @IBAction func buttonTapped(sender: AnyObject) {
        println("button tapped")
        self.settingsButton.setImage(UIImage(named: "Info Selected"), forState: UIControlState.Normal)
        animateSettings()
        self.settingsButton.setImage(UIImage(named: "Info"), forState: UIControlState.Normal)
    }

    
    @IBAction func logoutTapped(sender: AnyObject) {
        self.settingsOpen = true
        animateSettings()
        info.newLogin = true
        info.setUp = false
    }
    
    @IBAction func infoTapped(sender: AnyObject) {
    
    }
    
    func animateSettings() {
        println("animate settings")
      
        UIView.animateWithDuration(0.5) {
            // changes made in here will be animated
            println("animating")
            
            let width = self.settingsView.bounds.size.width
            let height = self.settingsView.bounds.size.height
            //let xCenter = (UIScreen.mainScreen().bounds.size.width / 2) - (self.settingsView.bounds.size.width / 2)
            let xCenter = self.settingsView.frame.origin.x
            
            if self.settingsOpen {
                
                self.settingsView.frame = CGRect(x: xCenter, y: -UIScreen.mainScreen().bounds.size.height / 2, width: width, height: height)
                
                
            } else {
            
                self.settingsView.frame = CGRect(x: xCenter, y: UIScreen.mainScreen().bounds.size.height / 3, width: width, height: height)
               
            }
            
            self.settingsOpen = !self.settingsOpen
        }
    }

}

extension PageContentViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(data.count ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        
        let row = indexPath.row
        let label = data[row] as Label
        cell.label = label
        
        return cell
    }
}

extension PageContentViewController: UITableViewDelegate {
   
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

}

extension PageContentViewController: UIScrollViewDelegate {
    
}

