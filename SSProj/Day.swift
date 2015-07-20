//
//  Day.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/16/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation

class Day {
    var dayName: String = ""
    var info: String = ""
    var rank: String = ""
    
    init(d: String, i: String, r: String) {
        dayName = d
        info = i
        rank = r
    }
}