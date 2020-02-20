//
//  NoteViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    var selectedDate: Date?

    @IBAction func moveToCalender(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
