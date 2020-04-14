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
    fileprivate static let userReferenceKey = "userReference"
}

class Disc {
    var discImage: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }

    let brand: String
    let mold: String
    let color: String?
    let plastic: String
    let flightPath: String?
    let run: Int?

    var userReference: CKRecord.Reference?
    var user: User?
    var recordID: CKRecord.ID
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

    init(discImage: UIImage, brand: String, mold: String, color: String?, plastic: String, flightPath: String?, run: Int?, userReference: CKRecord.Reference?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.discImage = discImage
        self.brand = brand
        self.mold = mold
        self.color = color
        self.plastic = plastic
        self.flightPath = flightPath
        self.run = run
        self.userReference = userReference
        self.recordID = recordID
    }
}

extension Disc {
    convenience init?(ckRecord: CKRecord) {
        guard let brand = ckRecord[DiscStrings.brandKey] as? String,
              let mold = ckRecord[DiscStrings.moldKey] as? String,
              let color = ckRecord[DiscStrings.colorKey] as? String,
              let plastic = ckRecord[DiscStrings.plasticKey] as? String,
              let flightPath = ckRecord[DiscStrings.flightPathKey] as? String,
              let run = ckRecord[DiscStrings.runKey] as? Int
                else { return nil }
        let userReference = ckRecord[DiscStrings.userReferenceKey] as? CKRecord.Reference

        var foundPhoto: UIImage?

        if let photoAsset = ckRecord[DiscStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Could not transform asst to data")
            }
        }
        self.init(discImage: foundPhoto ?? #imageLiteral(), brand: brand, mold: mold, color: color, plastic: plastic, flightPath: flightPath, run: run, userReference: userReference)
    }
}

extension  CKRecord {
    convenience init(disc: Disc) {
        self.init(recordType: DiscStrings.recordTypeKey, recordID: disc.recordID)

        self.setValuesForKeys([

            DiscStrings.brandKey : disc.brand,
            DiscStrings.moldKey : disc.mold,
            DiscStrings.colorKey : disc.color,
            DiscStrings.plasticKey : disc.plastic,
            DiscStrings.flightPathKey : disc.flightPath,
            DiscStrings.runKey : disc.run
        ])

        if disc.photoAsset != nil {
            self.setValue(disc.photoAsset, forKey: DiscStrings.photoAssetKey)
        }

        if disc.userReference != nil {
            self.setValue(disc.userReference, forKey: DiscStrings.userReferenceKey)
        }
    }
}