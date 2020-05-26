//
//  ReportController.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/20/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import Foundation
import CloudKit

class ReportController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    let privateDB = CKContainer.default().privateCloudDatabase
    //let flaggedZoneID = CKRecordZone.ID(zoneName: "FlaggedContent", ownerName: <#T##String#>)
    let contentToBeReviewed = CKRecord.ID(recordName: "FlaggedContent")
    //let report = CKRecord(recordType: "Report", recordID: contentToBeReviewed)
    
    func saveReport(user: User, collection: Collection?, disc: Disc?, reportedBy: User, completion: @escaping (Result<Report?, ReportError>) -> Void) {
        
        guard let currentUser = UserController.shared.currentUser else { return completion(.failure(.noUserLoggedIn))}
        
        let reportedByReference = CKRecord.Reference(recordID: currentUser.userCKRecordID, action: .deleteSelf)
        let userReference = CKRecord.Reference(recordID: user.userCKRecordID, action: .deleteSelf)
        
        if collection == nil && disc == nil {
            
            let newReport = Report(user: userReference, collection: nil, disc: nil, reportedBy: reportedByReference)
            
            let reportRecord = CKRecord(report: newReport)
            
            publicDB.save(reportRecord) { (record, error) in
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = record, let savedReport = Report(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
                print("Saved Record: \(record.recordID.recordName) successfully")
                completion(.success(savedReport))
            }
            
        } else if disc == nil {
            
            let collectionsReference = CKRecord.Reference(recordID: collection!.collectionCKRecordID, action: .deleteSelf)
            
            let newReport = Report(user: userReference, collection: collectionsReference, disc: nil, reportedBy: reportedByReference)
            
            let reportRecord = CKRecord(report: newReport)
            
            publicDB.save(reportRecord) { (record, error) in
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = record, let savedReport = Report(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
                print("Saved Record: \(record.recordID.recordName) successfully")
                completion(.success(savedReport))
            }
            
        }else if collection == nil {
            let discReference = CKRecord.Reference(recordID: disc!.discCKRecordID, action: .deleteSelf)
            
            let newReport = Report(user: userReference, collection: nil, disc: discReference, reportedBy: reportedByReference)
            
            let reportRecord = CKRecord(report: newReport)
            
            publicDB.save(reportRecord) { (record, error) in
                if let error = error {
                    return completion(.failure(.ckError(error)))
                }
                
                guard let record = record, let savedReport = Report(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
                print("Saved Record: \(record.recordID.recordName) successfully")
                completion(.success(savedReport))
            }
        } else {
            print("No object existed.")
            return completion(.failure(.couldNotUnwrap))
        }
    }
}
