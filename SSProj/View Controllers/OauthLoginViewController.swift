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
    var info = Info.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.hidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        if segue.identifier == "unwindToMenu" && segue.destinationViewController.isKindOfClass(RootViewController.classForCoder()) {
            let navViewController = segue.destinationViewController as! RootViewController
            if let user = sender?.valueForKey("user") as? User {
               self.info.user = user
            }
        }
    }

}

extension OauthLoginViewController: UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URLString
        if let range = urlString.rangeOfString(Instagram.Router.redirectURI + "?code=") {
            //receive code, request AccessToken
            let location = range.endIndex
            let code = urlString.substringFromIndex(location)
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
                    let json = JSON(jsonObject!)
                    
                    if let accessToken = json["access_token"].string, userID = json["user"]["id"].string {
                        let user = User()
                        user.userID = userID
                        user.accessToken = accessToken
                        
                        let realm = Realm()
                        
                        realm.write() {
                            if (realm.objects(User).first == nil) {
                                realm.add(user)
                            } else {
                                realm.objects(User).first!.userID = userID
                                realm.objects(User).first!.accessToken = accessToken
                            }
                        }
                        
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