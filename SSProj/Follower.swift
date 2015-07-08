//
//  Follower.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/6/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Follower : Object {
    
    dynamic var followerID: String = ""
    dynamic var followerUsername: String = ""
    dynamic var followerFullName: String = ""
    
    required init() {
        super.init()
    }
    
    required init(id: String, un: String, fn: String) {
        super.init()
        followerID = id
        followerUsername = un
        followerFullName = fn
    }
    
}