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

    override func viewDidLoad() {
        super.viewDidLoad()
        let ref = FIRDatabase.database().reference()
        let projects = ["3-D Printing", "Animatronics", "Arcade Game", "Bubble Machine", "Collapsible Bridge", "Concrete Canoe", "Educational Computer Game", "Fabric Bucket", "Hovercraft", "Music Maker", "Nuclear Probe", "GE's Precision Launcher", "Toy Design", "Water Fountain"]
        //ref.child("Teams").setValue(projects)
        for project in projects {
            ref.child("Scores").child(project).child("Team A").setValue(arc4random_uniform(20).distance(to: 0) * -1)
            ref.child("Scores").child(project).child("Team B").setValue(arc4random_uniform(20).distance(to: 0) * -1)
            ref.child("Scores").child(project).child("Team C").setValue(arc4random_uniform(20).distance(to: 0) * -1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

