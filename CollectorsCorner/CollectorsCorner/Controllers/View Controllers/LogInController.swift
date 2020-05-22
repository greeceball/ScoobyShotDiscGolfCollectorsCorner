//
//  LogInViewController.swift
//  CollectorsCorner
//
//  Created by Colby Harris on 4/19/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import UIKit
import AuthenticationServices

class LogInViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    //MARK: - Properties and Outlets
    @IBOutlet weak var loginProviderStackView: UIStackView!
    @IBOutlet weak var secondaryStackView: UIStackView!
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSignInAppleButton()
    }
    
    func setUpSignInAppleButton() {
        let signInBtn = ASAuthorizationAppleIDButton()
        signInBtn.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        signInBtn.cornerRadius = 10
        //Add button on some view or stack
        
        secondaryStackView.addArrangedSubview(signInBtn)
        //self.loginProviderStackView.addArrangedSubview(signInBtn)
    }
    
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    
    
    func finishLoggingIn() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        guard let mainTabBarController = rootViewController as? TabBarController else { return }

        mainTabBarController.viewControllers = [CollectionsTableViewController()]

        UserDefaults.standard.setIsLoggedIn(value: true)

        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TabBarController, let _ = sender as? User {
            vc.user = self.user
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential :
            let userName = credentials.user
            let fullName = credentials.fullName
            let email = credentials.email
            print("User id is \(userName) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            
            guard let firstName = fullName?.givenName, let lastName = fullName?.familyName, let userEmail = email else { return }
            
            UserController.shared.doesRecordExist(inRecordType: "User", withField: "userName", equalTo: userName) { (result) in
                if result == false {
                    let user = UserController.shared.createUserWith(profileImage: nil, username: userName, firstName: firstName, lastName: lastName, email: userEmail, state: "nil", yearsCollecting: 0)
                    
                    UserController.shared.saveUser(user: user) { (result) in
                        switch result {
                        case true:
                            self.user = user
                        case false:
                            print("An error occured when trying to save user to cloudKit.")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "UserName already exists", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                        
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true)
                        self.view.setNeedsDisplay()
                    }
                    UserDefaults.standard.set(true, forKey: "status")
                    
                }
            }
            
        case _ as ASPasswordCredential :
            break
        default:
            let alert = UIAlertController(title: "Apple SignIn", message: "Something went wrong with your Apple SignIn", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension LogInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
