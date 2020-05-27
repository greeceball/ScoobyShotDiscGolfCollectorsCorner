//
//  User.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/13/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit
import CloudKit
import AuthenticationServices

struct UserConstants {
    
    static let TypeKey = "User"
    //static let appleUserRefKey = "appleUserRef"
    //fileprivate static let profileImageKey = "profileImage"
    fileprivate static let usernameKey = "userName"
    fileprivate static let firstNameKey = "firstName"
    fileprivate static let lastNameKey = "lastName"
    fileprivate static let emailKey = "email"
    fileprivate static let collectionIDKey = "collectionID"
    
}

class User {
    
    var username: String
    let firstName: String
    let lastName: String
    var email: String
    var myCollection: String
    let userCKRecordID: CKRecord.ID
    
    init(username: String, firstName: String, lastName: String, email: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), myCollection: String?) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.userCKRecordID = ckRecordID
        self.myCollection = myCollection ?? ""
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[UserConstants.usernameKey] as? String,
            let firstName = ckRecord[UserConstants.firstNameKey] as? String,
            let lastName = ckRecord[UserConstants.lastNameKey] as? String,
            let email = ckRecord[UserConstants.emailKey] as? String,
            let myCollection = ckRecord[UserConstants.collectionIDKey] as? String
            else { return nil }

        self.init(username: username, firstName: firstName, lastName: lastName, email: email, myCollection: myCollection)
    }
}

extension  CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserConstants.TypeKey, recordID: user.userCKRecordID)
        self.setValuesForKeys([
            UserConstants.usernameKey : user.username,
            UserConstants.firstNameKey : user.firstName,
            UserConstants.lastNameKey : user.lastName,
            UserConstants.emailKey : user.email,
            UserConstants.collectionIDKey : user.myCollection,
        ])
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userCKRecordID == rhs.userCKRecordID
    }
}

extension User: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        if username.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}
