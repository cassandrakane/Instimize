//
//  Info.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/20/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation

class Info {
    var times: [Time] = []
    var days: [Day] = []
    var months: [Month] = []
    
    class var sharedInstance : Info {
        struct Static {
            static let instance : Info = Info()
        }
        return Static.instance
    }
    
    /*
    init(t: [Time], d: [Day], m: [Month]) {
        times = t
        days = d
        months = m
    }
    */
    
}