//
// Created by Colby Harris on 4/13/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import CloudKit
import UIKit

class PersonController {
    // Mark: - Shared instance
    static let shared = PersonController()

    // Mark: - Source of Truth
    var collectors: [Person] = []

    // Mark: - CRUD Func's
    // Mark: - Create
    func createUser(profileImage: UIImage, username: String, name: String, email: String, state: String, yearsCollecting: Int) {
        let newUser = Person.init(profileImage: profileImage, username: username, name: name, email: email, state: state, yearsCollecting: yearsCollecting)
        collectors.append(newUser)

    }


    // Mark: - Read

    // Mark: - Update

    // Mark: - Delete

}
