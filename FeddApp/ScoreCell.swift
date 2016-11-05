//
//  ScoreCell.swift
//  FeddApp
//
//  Created by Ziad Ali on 11/5/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit

class ScoreCell: UITableViewCell {

    @IBOutlet var score: UILabel!
    @IBOutlet var teamName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
