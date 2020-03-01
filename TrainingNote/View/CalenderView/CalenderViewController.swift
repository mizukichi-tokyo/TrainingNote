//
//  CalenderViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

class CalenderViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, Injectable {
    typealias Dependency = CalenderViewModel
    private let viewModel: CalenderViewModel

    @IBAction func moveToSetting(_ sender: Any) {
        calenderToSetting()
    }
    @IBAction func moveToNote(_ sender: Any) {
        calenderToNote()
    }

    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private var selectedDate = Date()
    private var records: Results<Record>!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            UINib(nibName: "CalenerTableViewCell", bundle: nil),
            forCellReuseIdentifier: R.reuseIdentifier.customCalenderTableCell.identifier
        )

        let realm = createRealm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        records = realm.objects(Record.self).sorted(byKeyPath: "creationTime", ascending: false)

        Observable.changeset(from: records)
            .subscribe(onNext: { [unowned self] _, changes in
                if let changes = changes {
                    self.tableView.applyChangeset(changes)
                    self.calendar.reloadData()
                } else {
                    self.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs?.dateDriver
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)
    }

}

extension CalenderViewController {

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        let dateFormatter = DateFormatter()
        // DateFormatter を使用して書式とローカルを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d/yyyy", options: 0, locale: Locale(identifier: "ja_JP"))

        var dateString = String()
        dateString = dateFormatter.string(from: date)

        dateLabel.text = dateString
        selectedDate = date
        self.tableView.reloadData()
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateFormatter = DateFormatter()
        // DateFormatter を使用して書式とローカルを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d/yyyy", options: 0, locale: Locale(identifier: "ja_JP"))

        var selectedDateArray: [String]
        selectedDateArray =  records.map { dateFormatter.string(from: $0.selectedDate)}

        var dateString = String()
        dateString = dateFormatter.string(from: date)

        if selectedDateArray.contains(dateString) {
            print(date)
            return 1
        }

        return 0
    }

}

extension CalenderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = records[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCalenderTableCell.identifier)!

        let roundWeight = round(record.weight * 10)/10
        cell.textLabel?.text = String(format: "% 3.0f", record.reps) + " reps  " + String(format: "% 5.1f", roundWeight) + " kg"

        cell.textLabel?.textColor = UIColor.lightText

        cell.detailTextLabel?.text = record.exercise
        cell.detailTextLabel?.textColor = UIColor.lightText

        cell.textLabel?.font = UIFont(name: "SFMono-Regular", size: 17)

        return cell
    }
}

extension CalenderViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            Observable.from([records[indexPath.row]])
                .subscribe(Realm.rx.delete())
                .disposed(by: disposeBag)
        }
    }
}

extension UITableView {
    func applyChangeset(_ changes: RealmChangeset) {
        beginUpdates()
        deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        endUpdates()
    }
}

extension CalenderViewController {
    func createRealm() -> Realm {
        do {
            return try Realm()
        } catch let error as NSError {
            assertionFailure("realm error: \(error)")
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            // swiftlint:disable:next force_try
            return try! Realm(configuration: config)
            // swiftlint:disable:previous force_try
        }
    }
}

extension CalenderViewController {
    private func calenderToSetting() {
        let viewContoller = SettingViewController.makeVC()
        viewContoller.modalPresentationStyle = .fullScreen
        present(viewContoller, animated: true, completion: nil)
    }

    private func calenderToNote() {
        let viewContoller = NoteViewController.makeVC()
        viewContoller.selectedDate = selectedDate
        viewContoller.modalPresentationStyle = .fullScreen
        present(viewContoller, animated: true, completion: nil)
    }
}

extension CalenderViewController {
    static func makeVC () -> CalenderViewController {
        let viewModel = CalenderViewModel(with: CalenderViewModel.Dependency.init())
        let viewControler = CalenderViewController(with: viewModel)
        return viewControler
    }
}
