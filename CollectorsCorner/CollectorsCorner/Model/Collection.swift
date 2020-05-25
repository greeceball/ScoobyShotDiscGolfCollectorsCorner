//
//  Collection.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/13/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//


import UIKit
import CloudKit

struct CollectionStrings {
    
    static let recordTypeKey = "Collection"
    fileprivate static let collectionImageKey = "collectionImage"
    fileprivate static let collectorUserNameKey = "collectorUserName"
    fileprivate static let collectorStateOfOriginKey = "collectorStateOfOrigin"
    fileprivate static let collectorNumOfYearsCollectingKey = "collectorNumOfYearsCollecting"
    fileprivate static let photoAssetKey = "photoAsset"
    fileprivate static let userReferenceKey = "userReference"
    
}

class Collection {
    
    let collectorUserName: String
    let collectorStateOfOrigin: String
    var collectorNumOfYearsCollecting: Int = 0
    
    var userReference: CKRecord.Reference?
    var user: User?
    var collectionCKRecordID: CKRecord.ID
    var photoData: Data?
    
    var photoAsset: CKAsset? {
        get {
            guard photoData != nil else { return nil }
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
    
    var collectionImage: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(collectionImage: UIImage, collectorsUserName: String, collectorStateOfOrigin: String, collectorNumOfYearsCollecting: Int, userReference: CKRecord.Reference?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.collectorUserName = collectorsUserName
        self.collectorStateOfOrigin = collectorStateOfOrigin
        self.collectorNumOfYearsCollecting = collectorNumOfYearsCollecting
        self.userReference = userReference
        self.collectionCKRecordID = recordID
        self.collectionImage = collectionImage
    }
}

extension Collection {
    convenience init?(ckRecord: CKRecord) {
        guard let collectorUserName = ckRecord[CollectionStrings.collectorUserNameKey] as? String,
            let collectorStateOfOrigin = ckRecord[CollectionStrings.collectorStateOfOriginKey] as? String,
            let collectorNumOfYearsCollecting = ckRecord[CollectionStrings.collectorNumOfYearsCollectingKey] as? Int
            else { return nil }
        let userReference = ckRecord[CollectionStrings.userReferenceKey] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        
        if let photoAsset = ckRecord[CollectionStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data.")
            }
        }
        self.init(collectionImage: foundPhoto ?? #imageLiteral(resourceName: "NoImageAvailable"), collectorsUserName: collectorUserName, collectorStateOfOrigin: collectorStateOfOrigin, collectorNumOfYearsCollecting: collectorNumOfYearsCollecting, userReference: userReference)
    }
}

extension CKRecord {
    convenience init(collection: Collection) {
        self.init(recordType: CollectionStrings.recordTypeKey, recordID: collection.collectionCKRecordID)
        
        self.setValuesForKeys([
            
            CollectionStrings.collectorUserNameKey : collection.collectorUserName,
            CollectionStrings.collectorStateOfOriginKey : collection.collectorStateOfOrigin,
            CollectionStrings.collectorNumOfYearsCollectingKey : collection.collectorNumOfYearsCollecting
            
        ])
        
        if collection.photoAsset != nil {
            self.setValue(collection.photoAsset, forKey: CollectionStrings.photoAssetKey)
        }
        
        if collection.userReference != nil {
            self.setValue(collection.userReference, forKey: CollectionStrings.userReferenceKey)
        }
        
        if collection.collectionImage != nil {
            self.setValue(collection.collectionImage, forKey: CollectionStrings.collectionImageKey)
        }
    }
}
