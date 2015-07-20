//
//  Month.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/16/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation

class Month {
    var monthName: String = ""
    var info: String = ""
    var rank: String = ""
    
    init(m: String, i: String, r: String) {
        monthName = m
        info = i
        rank = r
    }
}