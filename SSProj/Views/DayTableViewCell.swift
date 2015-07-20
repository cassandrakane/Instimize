//
//  DayTableViewCell.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/20/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import UIKit

class DayTableViewCell: UITableViewCell {
    
    // initialize the date formatter only once, using a static computed property
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var day: Day? {
        didSet {
            if let day = day, dayLabel = dayLabel, infoLabel = infoLabel {
                //sets up note table cell
                self.dayLabel.text = day.dayName
                self.infoLabel.text = day.info
            }
        }
    }
    
}