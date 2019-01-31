//
//  ViewController.swift
//  UverBus
//
//  Created by Jamie Scott on 1/23/19.
//  Copyright © 2019 UverBus. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInVC: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    override func viewDidAppear(_ animated: Bool) {
        //User already signed in, so skip sign in
        if let alreadySignedIn = Auth.auth().currentUser {
            performSegue(withIdentifier: "skipSignIn", sender: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

