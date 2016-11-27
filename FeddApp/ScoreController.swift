//
//  ScoreController.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/9/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase

class ScoreController: UITableViewController {

    var scoringCriteria = [String]()
    var scoreFields = [UITextField()]
    var scoreNameField = UITextField()
    var morning = false
    var project = ""
    var teamName = ""
    var existingScores = [Int]()
    var existingScoreName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.tableView.tableFooterView = UIView()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadExistingScores(scores:[Int], scoreName:String) {
        existingScores = scores
        existingScoreName = scoreName
    }
    
    func loadProjectAndTeamData(isMorning:Bool, projectName:String, team:String) {
        morning = isMorning
        project = projectName
        teamName = team
    }

    func loadScoringCriteria(project:String) {
        let ref = FIRDatabase.database().reference().child("Projects").child(project)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var tempCriteria = [String]()
            for child in snapshot.children {
                let criteriaDict = (child as! FIRDataSnapshot).value as! [String:Any]
                let criteria = criteriaDict["name"] as! String
                print(criteria)
                tempCriteria.append(criteria)
            }
            self.scoreFields.removeAll()
            self.scoringCriteria = tempCriteria
            self.tableView.reloadData()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return scoringCriteria.count+2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "enterScoreCell", for: indexPath) as! EnterScoreCell
            cell.scoreField.keyboardType = UIKeyboardType.alphabet
            cell.scoreField.placeholder = "Name this score for future access"
            scoreNameField = cell.scoreField
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            if existingScoreName != "" {
                cell.scoreField.text = existingScoreName
                cell.scoreField.isUserInteractionEnabled = false
            }
            return cell
        }
        else if indexPath.section < scoringCriteria.count+1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "enterScoreCell", for: indexPath) as! EnterScoreCell
            scoreFields.append(cell.scoreField)
            if existingScores.count >= scoreFields.count {
                cell.scoreField.text = "\(existingScores[scoreFields.count-1])"
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! TeamHomeButtonCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Score Name"
        }
        else if section == scoringCriteria.count+1 {
            return " "
        }
        return scoringCriteria[section-1]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submit" {
            print("Returning")
            (segue.destination as! TeamHomeController).loadPlayersAndScores(project: project, team: teamName)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(identifier == "submit") {
            print("Submit!")
            let scoreName = scoreNameField.text
            var tempScores = [Int]()
            for field in scoreFields {
                let score = field.text
                if score != "" {
                    tempScores.append(Int(score!)!)
                    print("Score: " + score!)
                }
            }
            if tempScores.count == scoreFields.count && scoreName != "" {
                let scoreRef = FIRDatabase.database().reference().child("Teams").child(project).child(teamName).child("Scores")
                scoreRef.child(scoreName!).setValue(tempScores)
                return true
            }
            else {
                return false
            }
        }
        return true
    }
}
