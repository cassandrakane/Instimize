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
        
        case getCounts(String, String)
        case getRecent(String, String)
        case getLikes(String, String)
        case getComments(String, String)
        case getFollowers(String, String)
        case getFollowings(String, String)
        case requestOauthCode
        
        static func requestAccessTokenURLStringAndParms(code: String) -> (URLString: String, Params: [String: AnyObject]) {
            //returns URL String for access token & parameters
            let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
            let pathString = "/oauth/access_token"
            let urlString = Instagram.Router.baseURLString + pathString
            return (urlString, params)
        }
        
        /*
        static func requestRecentMediaURLStringAndParms(userID: String, accessToken: String) -> (URLString: String, Params: [String: AnyObject]) {
            let params = ["count": , "max_timestamp": , "access_token": accessToken, "min_timestamp": , "min_id": , "max_id": ]
            let pathString = "/v1/users/" + userID + "/media/recent"
            let urlString = Instagram.Router.baseURLString + pathString
            return (urlSTring, params)
        }
        */

        
        var URLRequest: NSURLRequest {
            let (path: String, parameters: [String: AnyObject]) = {
                switch self {
                case .getCounts (let userID, let accessToken):
                    let params: [String: AnyObject] = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID
                    return (pathString, params)
                case .getRecent (let userID, let accessToken):
                    let params: [String: AnyObject] = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID + "/media/recent"
                    return (pathString, params)
                case .getLikes (let mediaID, let accessToken):
                    let params = ["access_token": accessToken]
                    let pathString = "/v1/media/" + mediaID + "/likes"
                    return (pathString, params)
                case .getComments (let mediaID, let accessToken):
                    let params = ["access_token": accessToken]
                    let pathString = "/v1/media/" + mediaID + "/comments"
                    return (pathString, params)
                case .getFollowers (let userID, let accessToken):
                    let params = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID + "/followed-by"
                    return (pathString, params)
                case .getFollowings (let userID, let accessToken):
                    let params = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID + "/follows"
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
    //FIGURE OUT LATER
}