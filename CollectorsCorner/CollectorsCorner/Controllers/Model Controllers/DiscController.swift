//
// Created by Colby Harris on 4/13/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import CloudKit
import UIKit

class DiscController {
    // Mark: - Shared instance
    static let shared = DiscController()

    // Mark: - Source of Truth and properties
    var discsArray: [Disc] = []
//    var currentUser: User?
//    var currentCollection: Collection?
//    var currentDisc: Disc?

     let publicDB = CKContainer.default().publicCloudDatabase
    
    // Mark: - CRUD Func's
    // Mark: - Create
    func createDisc(brand: String, mold: String, color: String?, plastic: String?, flightPath: String?, run: Int?, discImage: UIImage?) -> Disc {
        let currentCollection = UserDefaults.standard.value(forKey: "userCollectionID") as! String 
        
        let newDisc = Disc(discImage: discImage, brand: brand, mold: mold, color: color, plastic: plastic, flightPath: flightPath, run: run, collectionRecordID: currentCollection)
        
        return newDisc
    }
    
    func saveDisc(disc: Disc, completion: @escaping (Result<Disc?, DiscError>) -> Void) {
                
        let discRecord = CKRecord(disc: disc)
        
        publicDB.save(discRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
            let savedDisc = Disc(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap))}
            
            print("Saved Disc: \(record.recordID.recordName) successfully.")
            completion(.success(savedDisc))
        }
    }
    
    // Mark: - Read
    func loadDisc(discId: CKRecord.ID, completion: @escaping (Result<Disc?, DiscError>) -> Void) {
        
        publicDB.fetch(withRecordID: discId) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            guard let myRecord = record else { return completion(.failure(.couldNotUnwrap))}
            guard let disc = Disc(ckRecord: myRecord) else { return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(disc))
            
        }
    }
    
    // Mark: - Update
    func updateDisc(_ disc: Disc, completion: @escaping (Result<Disc?, DiscError>) -> Void) {
        let record = CKRecord(disc: disc)
        
        let operationUpdate = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        operationUpdate.savePolicy = .changedKeys
        operationUpdate.qualityOfService = .userInteractive
        operationUpdate.modifyRecordsCompletionBlock = {(records, _, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
            let disc = Disc(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap))}
            
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            
            completion(.success(disc))
        }
        publicDB.add(operationUpdate)
    }
        
    // Mark: - Delete
    func deleteDisc(_ disc: Disc, completion: @escaping (Result<Bool, DiscError>) -> Void) {
        let operationDeleteDisc = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [disc.discCKRecordID])
        
        operationDeleteDisc.savePolicy = .changedKeys
        operationDeleteDisc.qualityOfService = .userInteractive
        operationDeleteDisc.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            if records?.count == 0 {
                print("Deleted Disc from Collection")
                completion(.success(true))
            } else {
                print("Unaccounted records were returned when trying to delete Disc")
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(operationDeleteDisc)
    }
    
}
