//
//  LeaderboardController.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/2/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardController: UITableViewController {

    var projects = [String]()
    var teams = [String:[String]]()
    var scores = [String:[Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.projects = tempProjects
            self.tableView.reloadData()
            self.addTeamObservers()                                             //After projects found, adds observer to every team
        })
    }
    
    func addTeamObservers() {
        let ref = FIRDatabase.database().reference().child("Scores")            //Reference to the scores node
        for project in projects {                                               //Iterates through projects in scores node
            let tempRef = ref.child(project)
            
            //Adds listener ordered by ascending value on every project within the scores node
            tempRef.queryOrderedByValue().observe(.value, with: { snapshot in
                var tempTeams = [String]()
                var tempScores = [Int]()
                for child in snapshot.children {                                //Iterates through teams in every project
                    let team = (child as! FIRDataSnapshot).key                  //Gets team name (key)
                    let score = (child as! FIRDataSnapshot).value               //Gets team score (value)
                    tempTeams.append(team)
                    tempScores.append(score as! Int)
                }
                self.teams[project] = tempTeams.reversed()                      //Stores teams and scores to associated project
                self.scores[project] = tempScores.reversed()                    //Reverses order so that highest scores are first
                for i in 0..<tempTeams.count {
                    print("Team: \(tempTeams[i]) with score: \(tempScores[i])")
                }
                self.tableView.reloadData()                                     //Reloads table view
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("Team Count: \(teams.count)")
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

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return projects[section]
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
