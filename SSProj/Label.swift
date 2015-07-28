//
//  Label.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/22/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation

class Label {
    var name: String = ""
    var likes: String = ""
    var posts: String = ""
    var rank: String = ""
    var photo: String = ""
    
    init(n: String, l: String, p: String, r: String, ph: String) {
        name = n
        likes = l
        posts = p
        rank = r
        photo = ph
    }
}