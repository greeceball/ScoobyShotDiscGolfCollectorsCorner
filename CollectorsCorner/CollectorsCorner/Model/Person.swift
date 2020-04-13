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

extension Person {
    convenience init?(ckRecord: CKRecord) {
        guard let profileImage = ckRecord[PersonConstants.profileImageKey] as? UIImage,
              let username = ckRecord[PersonConstants.usernameKey] as? String,
              let name = ckRecord[PersonConstants.nameKey] as? String,
              let email = ckRecord[PersonConstants.emailKey] as? String,
              let state = ckRecord[PersonConstants.stateKey] as? String,
              let yearsCollecting = ckRecord[PersonConstants.yearsCollectingKey] as? Int,
              let timestamp = ckRecord[PersonConstants.timestampKey] as? Date
              else { return nil }
        self.init(profileImage: profileImage, username: username, name: name, email: email, state: state, yearsCollecting: yearsCollecting, timeStamp: timestamp)
    }
}

extension  CKRecord {
    convenience init(user: Person) {
        self.init(recordType: PersonConstants.recordTypeKey, recordID: user.ckRecordID)
        self.setValuesForKeys([
            PersonConstants.profileImageKey : user.profileImage,
            PersonConstants.usernameKey : user.username,
            PersonConstants.nameKey : user.name,
            PersonConstants.emailKey : user.email,
            PersonConstants.stateKey : user.state,
            PersonConstants.yearsCollectingKey : user.yearsCollecting,
            PersonConstants.timestampKey : user.timestamp
        ])
    }
}