//
//  Following.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/6/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Following : Object {
    
    dynamic var followingID: String = ""
    dynamic var followingUsername: String = ""
    dynamic var followingFullName: String = ""
    
    required init() {
        super.init()
    }
    
    required init(id: String, un: String, fn: String) {
        super.init()
        followingID = id
        followingUsername = un
        followingFullName = fn
    }
}