//
//  SearchableRecord.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/18/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
