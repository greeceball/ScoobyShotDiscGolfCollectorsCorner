//
//  Person.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/13/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit
import CloudKit

struct PersonConstants{
    static let profileImageKey = "profileImage"
    static let usernameKey = "username"
    static let nameKey = "name"
    static let emailKey = "email"
    static let stateKey = "state"
    static let yearsCollectingKey = "yearsCollecting"
    static let timestampKey = "timestamp"
    static let recordTypeKey = "User"
}

class Person {
    var profileImage: UIImage
    let username: String
    let name: String
    var email: String = ""
    let state: String
    var yearsCollecting: Int = 0
    let timestamp: Date
    let ckRecordID: CKRecord.ID

    init(profileImage: UIImage, username: String, name: String, email: String, state: String, yearsCollecting: Int, timeStamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.profileImage = profileImage
        self.name = name
        self.username = username
        self.email = email
        self.state = state
        self.yearsCollecting = yearsCollecting
        self.timestamp = timeStamp
        self.ckRecordID = ckRecordID
    }
}
