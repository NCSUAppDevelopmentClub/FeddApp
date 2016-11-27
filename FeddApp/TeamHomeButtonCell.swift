//
//  TeamHomeButtonCell.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/16/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase

class TeamHomeButtonCell: UITableViewCell {

    @IBOutlet var button: UIButton!
    var isDisqualify = false
    var isPublish = false
    var isMorning = false
    var project = ""
    var teamName = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDisqualify() {
        button.setTitle("Disqualify", for: .normal)
        button.setTitleColor(.red, for: .normal)
        isDisqualify = true
        isPublish = false
    }
    
    func setPublish() {
        button.setTitle("Publish", for: .normal)
        isDisqualify = false
        isPublish = true
    }
    
    func setReference(project:String, teamName:String, morning:Bool) {
        self.project = project
        self.teamName = teamName
        self.isMorning = morning
    }

    @IBAction func buttonClicked(_ sender: AnyObject) {
        let ref = FIRDatabase.database().reference()
        if isDisqualify {
            let disqualifyValue = -1.0
            if isMorning {
                ref.child("Morning Scores").child(project).child(teamName).setValue(disqualifyValue)
            }
            else {
                ref.child("Afternoon Scores").child(project).child(teamName).setValue(disqualifyValue)
            }
        }
            
        else if isPublish {
            let teamRef = ref.child("Teams").child(project).child(teamName).child("Scores")
            var sum = 0.0
            var count = 0.0
            teamRef.observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    let tempArray = (child as! FIRDataSnapshot).value as! [Int]
                    if tempArray.count > 0 {
                        
                    }
                    var tempSum = 0.0
                    for item in tempArray {
                        tempSum += Double(item)
                    }
                    sum += tempSum
                    count += 1
                }
                var finalScore = 0.0
                if count > 0.0 {
                    finalScore = sum/count
                }
                finalScore = Double(round(100*finalScore)/100)
                
                if self.isMorning {
                    ref.child("Morning Scores").child(self.project).child(self.teamName).setValue(finalScore)
                }
                else {
                    ref.child("Afternoon Scores").child(self.project).child(self.teamName).setValue(finalScore)
                }
            })
        }
    }
}
