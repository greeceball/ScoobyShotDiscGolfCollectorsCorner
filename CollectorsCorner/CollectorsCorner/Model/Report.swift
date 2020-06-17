//
//  Report.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/20/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit
import CloudKit

struct ConstantFlaggedContent {
    
    static let TypeKey = "FlaggedContent"
    fileprivate static let DiscKey = "disc"
    fileprivate static let CollectionKey = "collection"
    fileprivate static let UserKey = "user"
    fileprivate static let reportedByKey = "reportedBy"
    fileprivate static let timestampKey = "timestamp"
}

class Report {
    
    let recordID: CKRecord.ID
    let timeStamp: Date
    let reportedBy: CKRecord.Reference
    let userReference: CKRecord.Reference
    let collectionReference: CKRecord.Reference?
    let discReference: CKRecord.Reference?
    
    init(user: CKRecord.Reference, collection: CKRecord.Reference?, disc: CKRecord.Reference?, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), timeStamp: Date = Date(), reportedBy: CKRecord.Reference) {
        
        self.recordID = ckRecordID
        self.reportedBy = reportedBy
        self.timeStamp = timeStamp
        self.userReference = user
        self.collectionReference = collection ?? nil
        self.discReference = disc ?? nil
    }
}

extension Report {
    convenience init?(ckRecord: CKRecord) {
        guard let userReference = ckRecord[ConstantFlaggedContent.UserKey] as? CKRecord.Reference?,
            let reportedBy = ckRecord[ConstantFlaggedContent.reportedByKey] as? CKRecord.Reference?,
            let collectionReference = ckRecord[ConstantFlaggedContent.CollectionKey] as? CKRecord.Reference?,
            let discReference = ckRecord[ConstantFlaggedContent.DiscKey] as? CKRecord.Reference?,
            let timeStamp = ckRecord[ConstantFlaggedContent.timestampKey] as? Date else { return nil }
        
        self.init(user: userReference!, collection: collectionReference, disc: discReference, timeStamp: timeStamp, reportedBy: reportedBy!)
    }
}

extension CKRecord {
    convenience init(report: Report) {
        self.init(recordType: ConstantFlaggedContent.TypeKey, recordID: report.recordID)
        
        self.setValuesForKeys([
        
            ConstantFlaggedContent.UserKey : report.userReference as Any,
            ConstantFlaggedContent.reportedByKey : report.reportedBy as Any,
            ConstantFlaggedContent.CollectionKey : report.collectionReference as Any,
            ConstantFlaggedContent.DiscKey : report.discReference as Any,
            ConstantFlaggedContent.timestampKey : report.timeStamp as Date
        ])
    }
}
