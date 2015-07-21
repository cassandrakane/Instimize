//
//  TestViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/21/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import LBBlurredImage

class TestViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!
    var screenHeight: CGFloat = CGFloat()
    
    var info = Info.sharedInstance
    var times: [Time] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var background: UIImage = UIImage(named: "TestTest")!
        
        self.screenHeight = UIScreen.mainScreen().bounds.size.height
        
        self.blurredImageView.setImageToBlur(background, blurRadius: 10, completionBlock: nil)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
      
        
        self.tableView.tableHeaderView = tableHeaderView
        
        times = info.times
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension TestViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(times.count ?? 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath) as! TimeTableViewCell //1
        
        let row = indexPath.row
        let time = times[row] as Time
        cell.time = time
        
        
        return cell
    }
}

extension TestViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}

extension TestViewController: UIScrollViewDelegate {
    
}
