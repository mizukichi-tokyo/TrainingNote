//
//  CalenerTableViewCell.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/28.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit

class CalenerTableViewCell: UITableViewCell {

    @IBOutlet weak var exerciseLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
