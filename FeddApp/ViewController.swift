//
//  ViewController.swift
//  FeddApp
//
//  Created by Ziad Ali on 10/26/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {

    var ref: FIRDatabaseReference = FIRDatabaseReference()
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func login(_ sender: AnyObject) {
        ref.child("Emails").setValue("yadda yad")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        ref = FIRDatabase.database().reference()
        let googleLogin = GIDSignInButton()
        self.view.addSubview(googleLogin)
        googleLogin.center = view.center
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            else {
                print("User logged in with Google")
            }
        })
    }
    
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

