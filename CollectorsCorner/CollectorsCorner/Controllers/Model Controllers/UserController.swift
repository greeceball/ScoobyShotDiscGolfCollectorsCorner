//
// Created by Colby Harris on 4/13/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import CloudKit
import UIKit

class UserController {
    // Mark: - Shared instance
    static let shared = UserController()
    var currentUser: User? = StoredVariables.shared.userInfo["user"] as? User
    // Mark: - Source of Truth and Properties
    var collectors: [User] = []
    let publicDB = CKContainer.default().publicCloudDatabase
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // Mark: - CRUD Func's
    // Mark: - Create
    func createUserWith(profileImage: UIImage?, username: String, firstName: String, lastName: String, email: String, state: String?, yearsCollecting: Int?, myCollection: String) -> User {
        
        let newUser = User(username: username, firstName: firstName, lastName: lastName, email: email, myCollection: myCollection)
        
        return newUser
    }
    
    func saveUser(user: User, completion: @escaping (Bool) -> Void) {
        
        let userRecord = CKRecord(user: user)
        // Call the save method on the database, pass in record
        publicDB.save(userRecord) { (record, error) in
            // Handle optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) : \(error)")
                completion(false)
                return
            }
            // Unwrap the saved record, unwrap the user initialized from that record
            guard let record = record,
                let _ = User(ckRecord: record)
                else { return completion(false)}
            
            print("Created User: \(record.recordID.recordName) successfully")
            
            completion(true)
        }
    }
    
    // Mark: - Read
    func fetchUser(completion: @escaping (Result<User, UserError>) -> Void) {
        // Fetch and Unwrap the appleUserRef to pass in for the predicate
        fetchAppleUserReference { (result) in
            switch result {
            case .success(let reference):
                // Unwrap reference, and if it doesnt exist return completion failure due to no user logged in
                guard let reference = reference else { return completion(.failure(.couldNotUnwrap))}
                // Init the predicate needed bu the query
                let predicate = NSPredicate(value: true)
                //let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserConstants.appleUserRefKey, reference])
                // Init the query to pass into the .perform method
                let query = CKQuery(recordType: UserConstants.TypeKey, predicate: predicate)
                // Implement the .perform method
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    // Handle optional error
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    // Unwrap the record and foundUser initialized from the record
                    guard let record = records?.first,
                        let foundUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap))}
                    print("Fetched User: \(record.recordID.recordName) successfully")
                    completion(.success(foundUser))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // Mark: - Update
    func updateUser(_ user: User, completion: @escaping (Bool) -> Void){
        let record = CKRecord(user: user)
        
        let operationUpdateUser = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operationUpdateUser.savePolicy = .changedKeys
        operationUpdateUser.qualityOfService = .userInteractive
        operationUpdateUser.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                return completion(false)
            }
            
            guard let record = records?.first,
                let user = User(ckRecord: record)
                else { return completion(false)}
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            completion(true)
        }
        publicDB.add(operationUpdateUser)
    }
    // Mark: - Delete
    func delete(_ user: User, completion: @escaping (Bool) -> Void) {
        let operationDeleteUser = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [user.userCKRecordID])
        
        operationDeleteUser.savePolicy = .changedKeys
        operationDeleteUser.qualityOfService = .userInteractive
        operationDeleteUser.modifyRecordsCompletionBlock = {records, _, error in
            if let error = error {
                return completion(false)
            }
            
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(true)
            } else {
                print("Unaccounted records were returned when trying to delete")
                return completion(false)
            }
        }
        publicDB.add(operationDeleteUser)
    }
    
    // Mark: - Helper Func's
    func fetchUserFor(_ collection: Collection, completion: @escaping (Result<User, UserError>) -> Void) {
        
        let userID = collection.collectorUserName
        
        let predicate = NSPredicate(format: "%K == %@", argumentArray: ["recordID", userID])
        let query = CKQuery(recordType: UserConstants.TypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
                return
            }
            guard let record = records?.first,
                let foundUser = User(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap))}
            print("Found user for collection.")
            completion(.success(foundUser))
        }
    }
    
    private func fetchAppleUserReference(completion: @escaping (Result<CKRecord.Reference?, UserError>) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                completion(.success(reference))
            }
        }
    }
}

extension UserController {
    func doesRecordExist(inRecordType: String, withField: String, equalTo: String, _ completion: @escaping (Bool) -> ()) {
        
        let predicate = NSPredicate(format: "\(withField) == %@", equalTo)
        let query = CKQuery(recordType: inRecordType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil, completionHandler: {results, error in
            print("2")
            guard let results = results else { return }
            if results.count != 0 {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
