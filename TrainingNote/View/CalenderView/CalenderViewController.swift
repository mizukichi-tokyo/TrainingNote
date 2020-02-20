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

    var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = todayGet()
    }

}

extension CalenderViewController {
    func todayGet() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        var todayDate = String()
        // DateFormatter を使用して書式とローカルを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d/yyyy", options: 0, locale: Locale(identifier: "en_US"))
        todayDate = dateFormatter.string(from: date)

        return todayDate
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)

        dateLabel.text = "\(month)/\(day)/\(year)"
        selectedDate = date
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
        noteVC.selectedDate = selectedDate
        noteVC.modalPresentationStyle = .fullScreen
        present(noteVC, animated: true, completion: nil)
    }
}
