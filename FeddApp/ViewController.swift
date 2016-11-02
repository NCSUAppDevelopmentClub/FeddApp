//
//  ViewController.swift
//  FeddApp
//
//  Created by Ziad Ali on 10/26/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    var ref: FIRDatabaseReference = FIRDatabaseReference()
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func login(_ sender: AnyObject) {
        ref.child("Emails").setValue("yadda yad")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

