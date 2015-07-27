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
        let frame: CGRect = UIScreen.mainScreen().bounds
        tableView.tableHeaderView!.bounds.size.height = UIScreen.mainScreen().bounds.size.height
        self.backgroundImage.image = UIImage(named: imageFile)
        self.backgroundImage.bounds = frame
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
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
                    data = [Label(n: "Error", i: "error", r: "#", p: "Test Image")]
                }
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

