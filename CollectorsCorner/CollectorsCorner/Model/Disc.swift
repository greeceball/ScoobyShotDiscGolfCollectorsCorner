//
//  Disc.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/13/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit.UIImage
import Foundation

class Disc {
    var discImage: UIImage
    let brand: String
    let mold: String
    let color: String?
    let plastic: String
    let flightPath: String?
    let run: String?

    init(discImage: UIImage, brand: String, mold: String, color: String?, plastic: String, flightPath: String?, run: String?) {
        self.discImage = discImage
        self.brand = brand
        self.mold = mold
        self.color = color
        self.plastic = plastic
        self.flightPath = flightPath
        self.run = run
    }
}
