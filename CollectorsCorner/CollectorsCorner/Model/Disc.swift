//
//  Disc.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/13/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit.UIImage

import CloudKit

struct DiscStrings {
    
    static let recordTypeKey = "Disc"
    fileprivate static let discImageKey = "discImage"
    fileprivate static let brandKey = "brand"
    fileprivate static let moldKey = "mold"
    fileprivate static let colorKey = "color"
    fileprivate static let plasticKey = "plastic"
    fileprivate static let flightPathKey = "flightPath"
    fileprivate static let runKey = "run"
    fileprivate static let photoAssetKey = "photoAsset"
    fileprivate static let collectionRecordIDKey = "collectionRecordID"
    
}

class Disc {
    
    var brand: String
    var mold: String
    var color: String?
    var plastic: String?
    var flightPath: String?
    var run: Int?
    var collectionRecordID: String
    var user: User?
    var discCKRecordID: CKRecord.ID
    var photoData: Data?
    
    var photoAsset: CKAsset? {
        get {
            // Not having this guard check will break being able to create discs without photos
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
    
    var discImage: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    init(discImage: UIImage?, brand: String, mold: String, color: String?, plastic: String?, flightPath: String?, run: Int?, collectionRecordID: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.brand = brand
        self.mold = mold
        self.color = color ?? "---"
        self.plastic = plastic ?? "---"
        self.flightPath = flightPath ?? "---"
        self.run = run ?? 0
        self.collectionRecordID = collectionRecordID
        self.discCKRecordID = recordID
        self.discImage = discImage
    }
}

extension Disc {
    convenience init?(ckRecord: CKRecord) {
        guard let brand = ckRecord[DiscStrings.brandKey] as? String,
            let mold = ckRecord[DiscStrings.moldKey] as? String,
            let color = ckRecord[DiscStrings.colorKey] as? String,
            let plastic = ckRecord[DiscStrings.plasticKey] as? String,
            let flightPath = ckRecord[DiscStrings.flightPathKey] as? String,
            let run = ckRecord[DiscStrings.runKey] as? Int,
            let collectionRecordID = ckRecord[DiscStrings.collectionRecordIDKey] as? String
            else { return nil }
        
        
        var foundPhoto: UIImage?
        
        if let photoAsset = ckRecord[DiscStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asset to data.")
            }
        }
        self.init(discImage: foundPhoto ?? #imageLiteral(resourceName: "NoImageAvailable"), brand: brand, mold: mold, color: color, plastic: plastic, flightPath: flightPath, run: run, collectionRecordID: collectionRecordID)
    }
}

extension  CKRecord {
    convenience init(disc: Disc) {
        self.init(recordType: DiscStrings.recordTypeKey, recordID: disc.discCKRecordID)
        
        self.setValuesForKeys([
            
            DiscStrings.brandKey : disc.brand,
            DiscStrings.moldKey : disc.mold,
            DiscStrings.colorKey : disc.color as Any,
            DiscStrings.plasticKey : disc.plastic as Any,
            DiscStrings.flightPathKey : disc.flightPath as Any,
            DiscStrings.runKey : disc.run as Any,
            DiscStrings.collectionRecordIDKey: disc.collectionRecordID
        ])
        
        if disc.photoAsset != nil {
            self.setValue(disc.photoAsset, forKey: DiscStrings.photoAssetKey)
        }
    }
}



