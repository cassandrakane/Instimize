//
//  MenuViewController.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/2/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Alamofire
import SwiftyJSON

class MenuViewController: UITabBarController {
    
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    var shouldLogin = false
    var nextURLRequest: NSURLRequest?
    let refreshControl = UIRefreshControl()

    var user: User? {
        didSet {
            if user != nil {
                println("test")
                let urlString = Instagram.Router.getRecent(user!.userID, user!.accessToken)
                getPosts(urlString)
                hideLogoutButtonItem(false)
            } else {
                println("other test")
                shouldLogin = true
                hideLogoutButtonItem(true)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu (segue : UIStoryboardSegue) {
        
    }

    func hideLogoutButtonItem(hide: Bool) {
        if hide {
            logoutButtonItem.title = ""
            logoutButtonItem.enabled = false
        } else {
            logoutButtonItem.title = "Logout"
            logoutButtonItem.enabled = true
        }
    }

    func requestAccessToken(code: String) {
        let request = Instagram.Router.requestAccessTokenURLStringAndParms(code)
        
        Alamofire.request(.POST, request.URLString, parameters: request.Params)
            .responseJSON {
                (_, _, jsonObject, error) in
                
                if (error == nil) {
                    //println(jsonObject)
                    let json = JSON(jsonObject!)
                    
                    if let accessToken = json["access_token"].string, userID = json["user"]["id"].string {
                        let user = User()
                        user.userID = userID
                        user.accessToken = accessToken
                        println("USER ID:" + user.userID)
                        println("ACCESS TOKEN:" + user.accessToken)
                        
                        /*
                        let realm = Realm()
                        realm.write() {
                        //FIGURE OUT L8TER
                        realm.add(user, update: true)
                        return
                        }
                        */
                        
                        self.performSegueWithIdentifier("unwindToMenu", sender: ["user": user])
                    }
                }
                
        }
    }
    
    func getPosts(request: URLRequestConvertible) {
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        /*
                        if let urlString = json["pagination"]["next_url"].URL {
                            self.nextURLRequest = NSURLRequest(URL: urlString)
                        } else {
                            self.nextURLRequest = nil
                        }
                        */
                        
                        let posts = json["data"].arrayValue
                        
                        var mediaIDs: [String] = []
                        var i: Int
                        for (i = 0; i < posts.count; i++) {
                            let mediaID = posts[i]["id"].string
                            mediaIDs.append(mediaID!)
                        }
                        
                        let allLikes: [[String]] = []
                        for (i = 0; i < mediaIDs.count; i++) {
                            let urlString = Instagram.Router.getLikes(mediaIDs[i], self.user!.accessToken)
                            let likes = self.getLikes(urlString)
                        }
                        
                        let allComments: [[String]] = []
                        for (i = 0; i < mediaIDs.count; i++) {
                            let urlString = Instagram.Router.getComments(mediaIDs[i], self.user!.accessToken)
                            let likes = self.getComments(urlString)
                        }
                        /*
                        
                        let lastItem = self.photos.count
                        self.photos.extend(photoInfos)
                        
                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                         */
                        
                    }
                    
                }
                
            }
            //self.populatingPhotos = false
            
        }
    }

    func getLikes(request: URLRequestConvertible) -> [String]{
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        let likes = json["data"]
                        //NSLog("LIKES")
                        //NSLog("\(likes)")
                        
                    }
                    
                }
                
            }
            
        }
        
        return []

    }
    
    func getComments(request: URLRequestConvertible) -> [String] {
        Alamofire.request(request).responseJSON() {
            (_ , _, jsonObject, error) in
            
            if (error == nil) {
                //println(jsonObject)
                let json = JSON(jsonObject!)
                
                if (json["meta"]["code"].intValue  == 200) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        
                        let comments = json["data"]
                        NSLog("COM")
                        NSLog("\(comments)")
                        
                    }
                    
                }
                
            }
            
        }
        
        return []

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
