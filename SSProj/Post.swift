//
//  Post.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/6/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Post : Object {
    
    dynamic var mediaID: String = ""
    //dynamic var likes: [Like] = []
    //dynamic var comments: [Comment] = []
    dynamic var numOfLikes: Int = 0
    dynamic var createdTime: String = ""
    
    
    convenience required init(id: String, nol: Int, ct: String) {
        self.init()
        mediaID = id
        //likes = l
        //comments = c
        numOfLikes = nol
        createdTime = ct
        //filter = f
    }

    
    func getDate() -> String {
        
        var gmtTimeInterval : NSTimeInterval = (createdTime as NSString).doubleValue
        var gmtDate = NSDate(timeIntervalSince1970: gmtTimeInterval)
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timezoneName: String = NSTimeZone.localTimeZone().name
        dateFormatter.timeZone = NSTimeZone(name: timezoneName)
        //dateFormatter.timeZone = NSTimeZone(name: "Pacific/Midway")
        
        println("Time Zone: \(timezoneName)")
        
        let localDateString = dateFormatter.stringFromDate(gmtDate) + "+0000"
        
        return localDateString
        //return gmtDate.description
    }
    
}