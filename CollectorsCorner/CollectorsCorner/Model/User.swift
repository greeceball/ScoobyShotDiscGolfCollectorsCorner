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
    
    static let profileImageKey = "profileImage"
    static let usernameKey = "username"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let emailKey = "email"
    static let stateKey = "state"
    static let yearsCollectingKey = "yearsCollecting"
    static let timestampKey = "timestamp"
    static let recordTypeKey = "User"
    static let appleUserRefKey = "appleUserRef"
    fileprivate static let photoAssetKey = "photoAsset"
    
}

class User {
    
    var username: String
    let firstName: String
    let lastName: String
    var email: String
    var state: String
    var yearsCollecting: Int = 0
    let timestamp: Date
    let userCKRecordID: CKRecord.ID
    
    var photoData: Data?
    
    var photoAsset: CKAsset {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    var profileImage: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(username: String, firstName: String, lastName: String, email: String, state: String?, yearsCollecting: Int?, timeStamp: Date = Date(), appleUserReference: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), profileImage: UIImage?) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.state = state ?? ""
        self.yearsCollecting = yearsCollecting ?? 0
        self.timestamp = timeStamp
        self.userCKRecordID = ckRecordID
        self.profileImage = profileImage
    }
}

extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let profileImage = ckRecord[UserConstants.profileImageKey] as? UIImage,
            let username = ckRecord[UserConstants.usernameKey] as? String,
            let firstName = ckRecord[UserConstants.firstNameKey] as? String,
            let lastName = ckRecord[UserConstants.lastNameKey] as? String,
            let email = ckRecord[UserConstants.emailKey] as? String,
            let state = ckRecord[UserConstants.stateKey] as? String,
            let yearsCollecting = ckRecord[UserConstants.yearsCollectingKey] as? Int,
            let timestamp = ckRecord[UserConstants.timestampKey] as? Date,
            let appleUserRef = ckRecord[UserConstants.appleUserRefKey] as? CKRecord.Reference
            else { return nil }
        self.init(username: username, firstName: firstName, lastName: lastName, email: email, state: state, yearsCollecting: yearsCollecting, timeStamp: timestamp, appleUserReference: appleUserRef, profileImage: profileImage)
    }
}

extension  CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserConstants.recordTypeKey, recordID: user.userCKRecordID)
        self.setValuesForKeys([
            UserConstants.profileImageKey : user.profileImage as Any,
            UserConstants.usernameKey : user.username,
            UserConstants.firstNameKey : user.firstName,
            UserConstants.lastNameKey : user.lastName,
            UserConstants.emailKey : user.email,
            UserConstants.stateKey : user.state,
            UserConstants.yearsCollectingKey : user.yearsCollecting,
            UserConstants.timestampKey : user.timestamp,
            UserConstants.photoAssetKey : user.photoAsset
        ])
    }
}
//extension User {
//    convenience init(credentials: ASAuthorizationAppleIDCredential){
//        self
//    }
//}
