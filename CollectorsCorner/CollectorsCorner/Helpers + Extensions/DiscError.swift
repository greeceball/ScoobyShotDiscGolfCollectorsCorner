//
// Created by Colby Harris on 4/14/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import Foundation

enum DiscError: Error {
    case ckError(Error)
    case couldNotUnwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    case noCollectionForDisc

    var errorDescription: String {
        switch self {

        case .ckError(let error):
        return error.localizedDescription
        case .couldNotUnwrap:
        return "Unable to find Disc."
        case .unexpectedRecordsFound:
        return "Unexpected records were returned when trying to delete."
        case .noUserLoggedIn:
        return "There is currently no user logged in."
        case .noCollectionForDisc:
        return "No collection was found to be associated with this disc."
        }
    }
}