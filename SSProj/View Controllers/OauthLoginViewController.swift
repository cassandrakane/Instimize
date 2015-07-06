//
//  OauthLoginViewController.swift
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

class OauthLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    //let realm = Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.hidden = true
        
        //clears urls?
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        //deletes all cookies
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies as? [NSHTTPCookie]{
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        //sets up login in Web View
        let request = NSURLRequest(URL: Instagram.Router.authorizationURL, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        self.webView.loadRequest(request)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToMenu" && segue.destinationViewController.isKindOfClass(MenuViewController.classForCoder()) {
            let menuViewController = segue.destinationViewController as! MenuViewController
            if let user = sender?.valueForKey("user") as? User {
               menuViewController.user = user
            }
        }
    }

}

extension OauthLoginViewController: UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        println("REQUEST URL: " + request.URLString)
        let urlString = request.URLString
        if let range = urlString.rangeOfString(Instagram.Router.redirectURI + "?code=") {
            //receive code, request AccessToken
            let location = range.endIndex
            let code = urlString.substringFromIndex(location)
            println("CODE: " + code)
            requestAccessToken(code)
            return false
        }
        return true
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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.hidden = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        
    }
}