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
    dynamic var likes: [Like] = []
    dynamic var comments: [Comment] = []
    
    required init() {
        super.init()
    }
    
    required init(id: String, l: [Like], c: [Comment]) {
        super.init()
        mediaID = id
        likes = l
        comments = c
    }
    
}