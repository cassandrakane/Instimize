//
//  MenuViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/16/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit

class MenuViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }

    /*
    override func viewDidAppear(animated: Bool) {
        println("View Did Appear")
        var nav = self.navigationController?.navigationBar
        nav?.frame=CGRectMake(0, 0, 320, 500)
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()

    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    func hideLogoutButtonItem(hide: Bool) {
        if hide {
            logoutButtonItem.title = ""
            logoutButtonItem.enabled = false
        } else {
            logoutButtonItem.title = "Logout"
            logoutButtonItem.enabled = true
        }
    }
*/
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        println("Button Tapped")
        var tabBarController = self
        tabBarController.selectedIndex = 0
    }


}
