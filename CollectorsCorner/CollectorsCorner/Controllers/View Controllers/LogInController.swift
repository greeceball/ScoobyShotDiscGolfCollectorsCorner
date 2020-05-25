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
    
    @IBOutlet weak var secondaryStackView: UIStackView!
    
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appleIDStateRevoked), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        setUpSignInAppleButton()
        //check if userdefaults are not nil
                if UserDefaults.standard.object(forKey: "user") != nil {
                    DispatchQueue.main.async {
                        self.finishLoggingIn()
                    }
                }
    }
    
    func setUpSignInAppleButton() {
        let signInBtn = ASAuthorizationAppleIDButton()
        signInBtn.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        signInBtn.cornerRadius = 10
        //Add button on some view or stack
        
        secondaryStackView?.addArrangedSubview(signInBtn)
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
    
    @objc func appleIDStateRevoked() {
        UserDefaults.standard.set(false, forKey: "status")
        UserDefaults.standard.set("", forKey: "userID")
        self.showLoginViewController()
    }
    
    func finishLoggingIn() {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "tabBarVC") as! TabBarController
        performSegue(withIdentifier: "toMainVC", sender: nil)
        //UIApplication.shared.window?.rootViewController = vc
        //        UIApplication.shared.windows.first?.makeKeyAndVisible()
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
                            UserDefaults.standard.set(true, forKey: "status")
                            UserDefaults.standard.set(credentials.user, forKey: "userID")
                            DispatchQueue.main.async {
                                self.finishLoggingIn()
                            }
                        case false:
                            print("An error occured when trying to save user to cloudKit.")
                        }
                    }
                } else if result == true {
                    DispatchQueue.main.async {
//                        let alertController = UIAlertController(title: "UserName already exists", message: nil, preferredStyle: .alert)
//                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//
//                        alertController.addAction(cancelAction)
//                        self.present(alertController, animated: true)
//                        self.view.setNeedsDisplay()
                        self.finishLoggingIn()
                    }
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

extension UIViewController {
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LogInViewController {
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
}
