//
//  Instagram.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/2/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Alamofire
import UIKit

struct Instagram {
    
    //test
    
    enum Router: URLRequestConvertible {
        static let baseURLString = "https://api.instagram.com"
        static let clientID = "59b34827ea0c4469be3f4efba67e9f82"
        static let redirectURI = "http://localhost/"
        static let clientSecret = "ba7368a3061445749c7c36126ad757f4"
        static let authorizationURL = NSURL(string: Router.baseURLString + "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code")!
        
        case getRecent(String, String)
     
        case requestOauthCode
        
        static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
            //returns URL String for access token & parameters
            let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
            let pathString = "/oauth/access_token"
            let urlString = Instagram.Router.baseURLString + pathString
            return (urlString, params)
        }

        
        var URLRequest: NSURLRequest {
            let (path, parameters): (String, [String: AnyObject]) = {
                switch self {
                case .getRecent (let userID, let accessToken):
                    let params: [String: AnyObject] = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID + "/media/recent"
                    return (pathString, params)
                case .requestOauthCode:
                    let pathString = "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code"
                    return ("/photos", [:])
                }
            }()
            
            let BaseURL = NSURL(string: Router.baseURLString)
            var URLRequest = NSURLRequest(URL: BaseURL!.URLByAppendingPathComponent(path))
            let encoding = Alamofire.ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}

extension Alamofire.Request {
    
}