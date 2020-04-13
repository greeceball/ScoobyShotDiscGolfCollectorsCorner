//
//  Person.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/13/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class Person {
    var profileImage: UIImage
    let name: String
    let username: String
    let email: String?
    let state: String
    let yearsCollecting: Int?

    init(profileImage: UIImage, name: String, username: String, email: String?, state: String, yearsCollecting: Int) {
        self.profileImage = profileImage
        self.name = name
        self.username = username
        self.email = email
        self.state = state
        self.yearsCollecting = yearsCollecting
    }
}