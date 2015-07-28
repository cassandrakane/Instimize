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
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var photoLabel: UIImageView!
    
    var label: Label? {
        didSet {
            if let label = label, dataLabel = dataLabel, likeLabel = likeLabel, postLabel = postLabel, rankLabel = rankLabel, photoLabel = photoLabel {
                //sets up note table cell
                self.dataLabel.text = label.name
                self.likeLabel.text = label.likes
                self.postLabel.text = label.posts
                self.rankLabel.text = label.rank
                self.photoLabel.image = UIImage(named: label.photo)
            }
        }
    }


}
