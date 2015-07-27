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
    var info: String = ""
    var rank: String = ""
    var photo: String = ""
    
    init(n: String, i: String, r: String, p: String) {
        name = n
        info = i
        rank = r
        photo = p
    }
}