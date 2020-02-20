//
//  CalenderViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit
import FSCalendar

class CalenderViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func moveToSetting(_ sender: Any) {
        calenderToSetting()
    }
    @IBAction func moveToNote(_ sender: Any) {
        calenderToNote()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        dateLabel.text = "\(year)年\(month)月\(day)日"
    }
}

extension CalenderViewController {
    private func calenderToSetting() {
        let viewContoller = SettingViewController.makeVC()
        viewContoller.modalPresentationStyle = .fullScreen
        present(viewContoller, animated: true, completion: nil)
    }

    private func calenderToNote() {
        let noteVC = NoteViewController()
        noteVC.modalPresentationStyle = .fullScreen
        present(noteVC, animated: true, completion: nil)
    }
}
