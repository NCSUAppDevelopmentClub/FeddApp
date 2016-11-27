//
//  CreateTeamController.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/17/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase

class CreateTeamController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let sectionTitles = ["Team Name", "Session", "Project", "Players", " "]
    let pickerView = UIPickerView()
    var teamNameField = UITextField()
    var projectPickerField = UITextField()
    var teamPlayersFields = [UITextField()]
    var sessionChooser = UISegmentedControl()
    //var name = ""
    //var players = [String]()
    //var chosenSession = "Morning Scores"
    //var project = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamPlayersFields.removeAll()
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.tableFooterView = UIView()
        pickerView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return projects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return projects[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        projectPickerField.text = projects[row]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return 5
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell", for: indexPath) as! EnterScoreCell
            teamNameField = cell.scoreField
            cell.scoreField.keyboardType = UIKeyboardType.alphabet
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath) as! SessionChooserCell
            sessionChooser = cell.sessionChooser
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell", for: indexPath) as! EnterScoreCell
            projectPickerField = cell.scoreField
            projectPickerField.inputView = pickerView
            return cell
        }
        else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addPlayerCell", for: indexPath) as! EnterScoreCell
            teamPlayersFields.append(cell.scoreField)
            cell.scoreField.keyboardType = UIKeyboardType.alphabet
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "submitCell", for: indexPath) as! SubmitTeamCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "submitTeam" {
            let teamName = teamNameField.text
            let session = sessionChooser.selectedSegmentIndex
            let projectName = projectPickerField.text
            var playerNames = [String]()
            for field in teamPlayersFields {
                if field.text != "" {
                    playerNames.append(field.text!)
                }
            }
            if teamName != "" && projectName != "" && playerNames.count > 0 {
                var sessionString = "Morning Scores"
                if session == 0 {
                    sessionString = "Morning Scores"
                }
                else {
                    sessionString = "Afternoon Scores"
                }
                addTeams(teamName: teamName!, sessionName: sessionString, projectName: projectName!, playerNames: playerNames)
                return true
            }
            else {
                return false
            }
        }
        return true
    }
    
    func addTeams(teamName:String, sessionName:String, projectName:String, playerNames:[String]) {
        let initialValue = 0.0
        let sessionRef = FIRDatabase.database().reference().child(sessionName).child(projectName)
        sessionRef.child(teamName).setValue(initialValue)
        
        let teamRef = FIRDatabase.database().reference().child("Teams").child(projectName).child(teamName)
        teamRef.child("Players").setValue(playerNames)
    }
}
