//
//  PageContentViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/22/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var pageIndex: Int = 0
    var imageFile: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundImage.image = UIImage(named: imageFile)
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
