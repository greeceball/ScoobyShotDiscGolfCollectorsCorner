//
// Created by Colby Harris on 4/13/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import CloudKit
import UIKit

class UserController {
    // Mark: - Shared instance
    static let shared = UserController()

    // Mark: - Source of Truth
    var collectors: [User] = []

    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Mark: - CRUD Func's
    // Mark: - Create
    func createUser(profileImage: UIImage, username: String, name: String, email: String, state: String, yearsCollecting: Int, completion: @escaping (Result<User?, UserError>) -> Void) {
        // Fetch the AppleID User Reference and handle User creation in the closure
        fetchAppleUserReference { (result) in
            // Switch on result of fetchAppleUserReference
            switch result {
            // Case Success take in the reference returned
            case .success(let reference):
                // Unwrap reference. If not reference exists return failure
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                // If Success create new user
                let newUser = User.init(username: username, name: name, email: email, state: state, yearsCollecting: yearsCollecting, profileImage: profileImage)
                // Create a CKRecord from the user just created
                let record = CKRecord(user: newUser)
                // Call the save method on the database, pass in record
                self.publicDB.save(record) { (record, error) in
                    // Handle optional error
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    // Unwrap the saved record, unwrap the user initialized from that record
                    guard let record = record,
                          let savedUser = User(ckRecord: record)
                            else { return completion(.failure(.couldNotUnwrap))}

                    print("Created User: \(record.recordID.recordName) successfully")
                    completion(.success(savedUser))
                }
            case .failure(let error):
            print(error.errorDescription)
            }
        }
    }


    // Mark: - Read
    func fetchUser(completion: @escaping (Result<User?, UserError>) -> Void) {
        // Fetch and Unwrap the appleUserRef to pass in for the predicate
        fetchAppleUserReference { (result) in
            switch result {
            case .success(let reference):
                // Unwrap reference, and if it doesnt exist return completion failure due to no user logged in
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                // Init the predicate needed bu the query
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserConstants.appleUserRefKey, reference])
                // Init the query to pass into the .perform method
                let query = CKQuery(recordType: UserConstants.recordTypeKey, predicate: predicate)
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
    func update(_ user: User, completion: @escaping (_ success: Bool) -> Void){

    }
    // Mark: - Delete
    func delete(_ user: User, completion: @escaping (_ success: Bool) -> Void) {

    }

    // Mark: - Helper Func's

    func fetchUserFor(_ collection: Collection, completion: @escaping (Result<User, UserError>) -> Void) {
        guard let userID = collection.userReference?.recordID else { return completion(.failure(.noUserForCollection))}
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