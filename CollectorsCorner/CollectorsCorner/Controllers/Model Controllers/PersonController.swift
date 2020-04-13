//
// Created by Colby Harris on 4/13/20.
// Copyright (c) 2020 Colby_Harris. All rights reserved.
//

import CloudKit
import UIKit

class PersonController {
    // Mark: - Source of Truth and Shared instance
    static let shared = PersonController()
    var users: [Person] = []

    // Mark: - CRUD Func's
    // Mark: - Create
    func createUser(profileImage: UIImage, username: String, name: String, email: String?, state: String, yearsCollecting: Int?) {
        guard let email = email, !email.isEmpty, let yearsCollecting = yearsCollecting, yearsCollecting != 0 else { return }
        Person.init(profileImage: profileImage, username: username, name: name, email: email, state: state, yearsCollecting: yearsCollecting)
    }


    // Mark: - Read

    // Mark: - Update

    // Mark: - Delete

}
