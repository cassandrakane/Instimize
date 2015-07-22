//
//  TableViewCell.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/22/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    var label: Label? {
        didSet {
            if let label = label, dataLabel = dataLabel, infoLabel = infoLabel, rankLabel = rankLabel {
                //sets up note table cell
                self.dataLabel.text = label.name
                self.infoLabel.text = label.info
                self.rankLabel.text = label.rank
            }
        }
    }


}
