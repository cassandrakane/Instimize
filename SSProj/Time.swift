//
//  Time.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/16/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation

class Time {
    var timeName: String = ""
    var info: String = ""
    var rank: String = ""
    
    init(t: String, i: String, r: String) {
        timeName = t
        info = i
        rank = r
    }
}