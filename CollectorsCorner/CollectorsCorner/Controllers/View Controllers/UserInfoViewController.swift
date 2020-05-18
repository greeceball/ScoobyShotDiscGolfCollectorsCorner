//
//  UserInfoViewController.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 5/18/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    var user: User?
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view.
    }
    
    func updateLabels() {
        userNameLabel.text = user?.username
        firstNameLabel.text = user?.firstName
        lastNameLabel.text = user?.lastName
        emailLabel.text = user?.email
    }

    //autologin
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
