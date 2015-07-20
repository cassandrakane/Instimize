//
//  MonthTableViewCell.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/20/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import Foundation
import UIKit

class MonthTableViewCell: UITableViewCell {
    
    // initialize the date formatter only once, using a static computed property
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    var month: Month? {
        didSet {
            if let month = month, monthLabel = monthLabel, infoLabel = infoLabel, rankLabel = rankLabel {
                //sets up note table cell
                self.monthLabel.text = month.monthName
                self.infoLabel.text = month.info
                self.rankLabel.text = month.rank
            }
        }
    }
    
}