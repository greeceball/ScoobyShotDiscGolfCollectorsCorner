//
//  ReportError.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/20/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import Foundation

enum ReportError: Error {
    case ckError(Error)
    case couldNotUnwrap
    case noUserLoggedIn
    
    var errorDescription: String {
        switch self {

        case .ckError(let error):
            return error.localizedDescription
        case .couldNotUnwrap:
            return "Unable to find information"
        case .noUserLoggedIn:
            return "No user is logged in"
        }
    }
}
