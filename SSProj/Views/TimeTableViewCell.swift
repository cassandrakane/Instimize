//
//  TimeTableViewCell.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/20/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import UIKit

class TimeTableViewCell: UITableViewCell {
    
    // initialize the date formatter only once, using a static computed property
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    var time: Time? {
        didSet {
            if let time = time, timeLabel = timeLabel, infoLabel = infoLabel, rankLabel = rankLabel {
                //sets up note table cell
                self.timeLabel.text = time.timeName
                self.infoLabel.text = time.info
                self.rankLabel.text = time.rank
            }
        }
    }
    
}