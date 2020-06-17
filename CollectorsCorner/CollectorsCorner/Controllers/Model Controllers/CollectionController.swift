//
// Created by Colby Harris on 4/13/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import CloudKit
import UIKit

class CollectionController {
    
    // Mark: - Source of Truth and Shared instance
    var collectionsArray: [Disc?] = []
    static let shared = CollectionController()
    var currentCollection: Collection?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Mark: - CRUD Func's
    func createCollection(userName: String, stateOfOrgin: String, numOfYearsCollecting: Int, collectionImage: UIImage?) -> Collection {
        
        // Create new collection by initializing it and setting values
        let newCollection = Collection(collectionImage: collectionImage, collectorsUserName: userName, collectorStateOfOrigin: stateOfOrgin, collectorNumOfYearsCollecting: numOfYearsCollecting, discs: [])

        return newCollection
    }
    
    func saveCollection(collection: Collection, completion: @escaping (Result<Collection?, CollectionError>) -> Void) {
        
        // Create var collectionRecord and set equal to new collections CKRecord
        let collectionRecord = CKRecord(collection: collection)
        
        // Save collection to public data base
        publicDB.save(collectionRecord) { (record, error) in
            
            // Error handling
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            // Unwrap record, and savedCollection. set their values or return failure result
            guard let record = record, let savedCollection = Collection(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
            // Otherwise print success message and return completion success
            print("Saved Collection: \(record.recordID.recordName) successfully.")
            completion(.success(savedCollection))
        }
    }

    // Mark: - Read
    func fetchCollections(completion: @escaping (Result<[Collection]?, CollectionError>) -> Void) {
        // Create new predicate
        let predicate = NSPredicate(value: true)
        
        // Create new Query and set value
        let query = CKQuery(recordType: CollectionStrings.recordTypeKey, predicate: predicate)
        
        // fetch collections from public data base
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            // Error Handling
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            // Unwrap records or return failure
            guard let records = records else { return completion(.failure(.couldNotUnwrap))}
            
            // Otherwise print success message
            print("Fetched Collections Successfully")
            
            // and set Collections to the collections fetched from DB
            let collections = records.compactMap({ Collection(ckRecord: $0) })
            
            // Return completion success
            completion(.success(collections))
        }
    }
    
    func fetchCollection(for user: String, completion: @escaping (Result<Collection?, DiscError>) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CollectionStrings.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (record, error) in
        
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record else { return completion(.failure(.couldNotUnwrap))}
            
            print("Loaded Collection Successfully")
            
            let recordToConvert = record[0]
            guard let collection = Collection(ckRecord: recordToConvert) else {return completion(.failure(.couldNotUnwrap))}
            //let collection = record.compactMap({ Collection(ckRecord: $0) })
            //let collectionToReturn = Collection(collection)
            completion(.success(collection))
        }
    }
    
    // Mark: - Update
    func updateCollection(_ collection: Collection, completion: @escaping (Result<Collection?, CollectionError>) -> Void) {
        
        // Create record and set value
        let record = CKRecord(collection: collection)
        
        // Create Operation that will save changes
        let operationUpdate = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operationUpdate.savePolicy = .changedKeys
        operationUpdate.qualityOfService = .userInteractive
        operationUpdate.modifyRecordsCompletionBlock = { (records, _, error) in
            
            // Error Handling
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            // Unwrap Record, and Collection else return failure
            guard let record = records?.first,
            let collection = Collection(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap)) }
            
            // Otherwise Print successful
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            // completion successful
            completion(.success(collection))
        }
        // Perform the save to the database
        publicDB.add(operationUpdate)
    }
    
    // Mark: - Delete
    func deleteCollection(_ collection: Collection, completion: @escaping (Result<Bool, CollectionError>) -> Void) {
        
        // Create operation to delete collection from CloudKit
        let operationDelete = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [collection.collectionCKRecordID])
        
        operationDelete.savePolicy = .changedKeys
        operationDelete.qualityOfService = .userInteractive
        operationDelete.modifyRecordsCompletionBlock = {records, _, error in
            
            // Error Handling
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            // If record count is 0 then the records have successfully deleted
            if records?.count == 0 {
                print("Deleted record from CloudKit")
                completion(.success(true))
            } else {
                
                // Else records were still found after the delete operation was called, returned failure
                print("Unaccounted records were returned when trying to delete")
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        // Perform the delete operation on data base
        publicDB.add(operationDelete)
    }
    func fetchUserForCollection() {
        
    }
    
}
