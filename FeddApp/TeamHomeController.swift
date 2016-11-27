//
//  TeamHomeController.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/9/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase

class TeamHomeController: UITableViewController {

    let sectionTitles = ["Players", "Scores", " ", " "]
    var players = [String]()
    var scores = [String:[Int]]()
    var morning = false
    var project = ""
    var teamName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.tableView.tableFooterView = UIView()
        self.refreshControl?.addTarget(self, action: #selector(TeamHomeController.refresh), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setSession(morningSession:Bool) {
        morning = morningSession
    }
    
    func refresh() {
        loadPlayersAndScores(project: project, team: teamName)
    }
    
    func loadPlayersAndScores(project:String, team:String) {
        let ref = FIRDatabase.database().reference().child("Teams").child(project).child(team)
        let playersRef = ref.child("Players")
        let scoresRef = ref.child("Scores")
        self.project = project
        self.teamName = team
        
        playersRef.observeSingleEvent(of: .value, with: { snapshot in
            var tempPlayers = [String]()
            for player in snapshot.children {
                let playerName = (player as! FIRDataSnapshot).value
                if playerName is String {
                    tempPlayers.append(playerName as! String)
                    print(playerName)
                }
            }
            self.players = tempPlayers
            print("Players: \(self.players)")
            self.tableView.reloadData()
        })
        
        scoresRef.observeSingleEvent(of: .value, with: { snapshot in
            var tempScores = [String:[Int]]()
            for fullScore in snapshot.children {
                let scoreArray = (fullScore as! FIRDataSnapshot)
                let scoreName = scoreArray.key
                if let scoreValues = scoreArray.value {
                    print("Score Name: \(scoreArray.key)")
                    print("Scores: \(scoreArray.value)")
                    tempScores[scoreName as String] = scoreValues as? [Int]
                }
            }
            self.scores = tempScores
            print("Scores: \(self.scores)")
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return players.count
        }
        else if section == 1 {
            return scores.count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
            cell.textLabel?.text = players[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scoreCell", for: indexPath) as! ScoreCell
            let scoreNames = Array(scores.keys)
            cell.teamName.text = scoreNames[indexPath.row]
            var sum = 0
            for score in scores[scoreNames[indexPath.row]]! {
                sum += score
            }
            cell.score.text = "\(sum)"
            return cell
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! TeamHomeButtonCell
            cell.setDisqualify()
            cell.setReference(project: project, teamName: teamName, morning: morning)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell", for: indexPath) as! TeamHomeButtonCell
            cell.setPublish()
            cell.setReference(project: project, teamName: teamName, morning: morning)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is ScoreCell {
            let cell = tableView.cellForRow(at: indexPath) as! ScoreCell
            let scoreName = cell.teamName.text
            performSegue(withIdentifier: "editScore", sender: scoreName)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < 2 {
            return 30
        }
        return 15
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addScore" {
            (segue.destination as! ScoreController).loadProjectAndTeamData(isMorning: morning, projectName: project, team: teamName)
            (segue.destination as! ScoreController).loadScoringCriteria(project: project)
        }
        
        else if segue.identifier == "editScore" {
            let scoreController = segue.destination as! ScoreController
            scoreController.loadProjectAndTeamData(isMorning: morning, projectName: project, team: teamName)
            scoreController.loadScoringCriteria(project: project)
            let scoreName = sender as! String
            scoreController.loadExistingScores(scores: scores[scoreName]!, scoreName: scoreName)
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        //This needs to be here in order for the unwind in ScoreController to function
    }
}
