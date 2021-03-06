//
//  SettingsViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/28/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var info = Info.sharedInstance 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.scrollRangeToVisible(NSMakeRange(0, 0))
        // Do any additional setup after loading the view.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func logoutTapped(sender: AnyObject) {
        info.setUp = false
        let realm = Realm
        
        let oldUser = realm.objects(User).first!
        var newUser: User = User()
        realm.write() {
            realm.add(newUser)
            realm.delete(oldUser)
        }
    }


}
