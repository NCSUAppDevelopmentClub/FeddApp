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

class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet var googleSignInButton: GIDSignInButton!
    @IBOutlet var leaderboardButton: UIButton!
    @IBOutlet var feddTitle: UILabel!
    @IBOutlet var feddDescription: UILabel!
    @IBOutlet var ncStateLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var leaderboardButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        //GIDSignIn.sharedInstance().signInSilently()
        feddTitle.adjustsFontSizeToFitWidth = true
        feddDescription.adjustsFontSizeToFitWidth = true
        ncStateLabel.adjustsFontSizeToFitWidth = true
        self.navigationController?.navigationBar.isHidden = true
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.style = GIDSignInButtonStyle.iconOnly
        
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        buttonView.layer.shadowRadius = 3
        buttonView.layer.shadowOpacity = 0.7
        buttonView.layer.cornerRadius = 5
        
        leaderboardButtonView.layer.shadowColor = UIColor.black.cgColor
        leaderboardButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        leaderboardButtonView.layer.shadowRadius = 3
        leaderboardButtonView.layer.shadowOpacity = 0.7
        leaderboardButtonView.layer.cornerRadius = 5
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            print("User auth state changed")
        })
        
        let ref = FIRDatabase.database().reference().child("Emails")
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let email = (child as! FIRDataSnapshot).value as! String
                emails.append(email)
                print(email)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLeaderboard" {
            self.navigationItem.backBarButtonItem?.title = " "
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("Signed in 2")
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            print("Signing in 2!")
            self.performSegue(withIdentifier: "showLeaderboard", sender: nil)
        }
    }
    
    func sign(didDisconnectWithUser user:GIDGoogleUser!, withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    @IBAction func signOut(_ sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
        GIDSignIn.sharedInstance().signOut()
    }
}

