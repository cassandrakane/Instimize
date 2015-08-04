//
//  User.swift
//  SSProj
//
//  Created by Cassandra Kane on 7/2/15.
//  Copyright (c) 2015 Cassandra Kane. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Realm

class User : Object {
    
    dynamic var userID: String = ""
    dynamic var accessToken: String = ""
    dynamic var posts = List<Post> ()
    dynamic var set: Bool = false

}
