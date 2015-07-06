//
//  Like.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/6/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Like : Object {
    
    dynamic var likerID: String = ""
    dynamic var likerUsername: String = ""
    dynamic var likerFullName: String = ""
    
}