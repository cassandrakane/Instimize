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
        
        tableView.tableHeaderView!.bounds.size.height = UIScreen.mainScreen().bounds.size.height + 90
        self.backgroundImage.image = UIImage(named: imageFile)
        
        bestDataTypeLabel.text = dataTypeString
        bestDataLabel.text = bestDataString
        
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
                    data = [Label(n: "Error", l: "error", p: "error", r: "#", ph: "Null")]
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.backgroundImage.bounds = CGRect(x: UIScreen.mainScreen().bounds.origin.x, y: UIScreen.mainScreen().bounds.origin.y, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height + 20)
        self.tableView.bounds = UIScreen.mainScreen().bounds
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUser() {
        let realm = Realm()
        user = realm.objects(User).first!
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

