//
//  LeaderboardController.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/2/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

var projects = [String]()
var morningTeams = [String:[String]]()
var morningScores = [String:[Double]]()
var afternoonTeams = [String:[String]]()
var afternoonScores = [String:[Double]]()
var teams = [String:[String]]()
var scores = [String:[Double]]()
var emails = [String]()

class LeaderboardController: UITableViewController {
    
    var tempScore = [String:[Int]]()
    @IBOutlet var sectionChooser: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem?.title = " "
        self.tableView.tableFooterView = UIView()
        getProjects()                                                           //Fills projects array with list of projects
    }
    
    func getProjects() {
        let ref = FIRDatabase.database().reference().child("Scores")            //Reference to the scores node
        
        //Uses one-time listener to get list of all project names
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var tempProjects = [String]()
            for child in snapshot.children {
                let project = (child as! FIRDataSnapshot).key
                tempProjects.append(project)
            }
            for project in tempProjects {
                print("Project: \(project)")
            }
            projects = tempProjects
            self.tableView.reloadData()
            self.addTeamObservers()                                             //After projects found, adds observer to every team
        })
    }
    
    func addTeamObservers() {
        var ref = FIRDatabase.database().reference().child("Morning Scores")            //Reference to the scores node
        for project in projects {                                               //Iterates through projects in scores node
            let tempRef = ref.child(project)
            
            //Adds listener ordered by ascending value on every project within the scores node
            tempRef.queryOrderedByValue().observe(.value, with: { snapshot in
                var tempTeams = [String]()
                var tempScores = [Double]()
                for child in snapshot.children {                                //Iterates through teams in every project
                    let team = (child as! FIRDataSnapshot).key                  //Gets team name (key)
                    let score = (child as! FIRDataSnapshot).value               //Gets team score (value)
                    tempTeams.append(team)
                    tempScores.append(score as! Double)
                }
                morningTeams[project] = tempTeams.reversed()                      //Stores teams and scores to associated project
                morningScores[project] = tempScores.reversed()                    //Reverses order so that highest scores are first
                for i in 0..<tempTeams.count {
                    print("Team: \(tempTeams[i]) with score: \(tempScores[i])")
                }
                teams = morningTeams
                scores = morningScores
                self.tableView.reloadData()                                     //Reloads table view
            })
        }
        
        ref = FIRDatabase.database().reference().child("Afternoon Scores")
        for project in projects {                                               //Iterates through projects in scores node
            let tempRef = ref.child(project)
            
            //Adds listener ordered by ascending value on every project within the scores node
            tempRef.queryOrderedByValue().observe(.value, with: { snapshot in
                var tempTeams = [String]()
                var tempScores = [Double]()
                for child in snapshot.children {                                //Iterates through teams in every project
                    let team = (child as! FIRDataSnapshot).key                  //Gets team name (key)
                    let score = (child as! FIRDataSnapshot).value               //Gets team score (value)
                    tempTeams.append(team)
                    tempScores.append(score as! Double)
                }
                afternoonTeams[project] = tempTeams.reversed()                      //Stores teams and scores to associated project
                afternoonScores[project] = tempScores.reversed()                    //Reverses order so that highest scores are first
                for i in 0..<tempTeams.count {
                    print("Team: \(tempTeams[i]) with score: \(tempScores[i])")
                }
                self.tableView.reloadData()                                     //Reloads table view
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        //print("Team Count: \(teams.count)")
        return teams.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return teams[projects[section]]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScoreCell
        
        // Configure the cell...
        let projectName = projects[indexPath.section]
        let teamArray = teams[projectName]!
        let scoreArray = scores[projectName]!
        let teamName = teamArray[indexPath.row]
        let score = scoreArray[indexPath.row]
        cell.teamName.text = teamName
        cell.score.text = "\(score)"
        if score < 0 {
            cell.score.text = "-"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return projects[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if FIRAuth.auth()?.currentUser?.email != nil {
            var email = ""
            email = (FIRAuth.auth()?.currentUser?.email!)!
            if emails.contains(email) {
                let cell = tableView.cellForRow(at: indexPath) as! ScoreCell
                let sectionHeaderView = tableView.headerView(forSection: indexPath.section)
                let sectionTitle = sectionHeaderView?.textLabel?.text
                if let project = sectionTitle {
                    if let teamName = cell.teamName.text {
                        print(teamName)
                        print(project)
                        performSegue(withIdentifier: "showTeamPage", sender: [project, teamName])
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeamPage" {
            if segue.destination is TeamHomeController {
                if sectionChooser.selectedSegmentIndex == 0 {
                    (segue.destination as! TeamHomeController).setSession(morningSession: true)
                }
                else {
                    (segue.destination as! TeamHomeController).setSession(morningSession: false)
                }
                
                let project = (sender as? [String])?[0]
                let teamName = (sender as? [String])?[1]
                segue.destination.navigationItem.title = (sender as? [String])?[1]
                (segue.destination as! TeamHomeController).loadPlayersAndScores(project: project!, team: teamName!)
            }
        }
    }
    
    @IBAction func sectionClicked(_ sender: AnyObject) {
        if sectionChooser.selectedSegmentIndex == 0 {
            teams = morningTeams
            scores = morningScores
        }
        else {
            teams = afternoonTeams
            scores = afternoonScores
        }
        tableView.reloadData()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "createTeam" {
            if FIRAuth.auth()?.currentUser?.email != nil {
                var email = ""
                email = (FIRAuth.auth()?.currentUser?.email!)!
                if emails.contains(email) {
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }
        return true
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        //This needs to be here in order for the unwind in TeamHomeController to function
    }
}
