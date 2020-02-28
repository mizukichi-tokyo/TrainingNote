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

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private var selectedDate = Date()
    private var records: Results<Record>!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            CalenerTableViewCell.self,
            forCellReuseIdentifier: R.reuseIdentifier.calenderTableCell.identifier
        )

        let realm = createRealm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        records = realm.objects(Record.self).sorted(byKeyPath: "creationTime", ascending: false)

        Observable.changeset(from: records)
            .subscribe(onNext: { [unowned self] _, changes in
                if let changes = changes {
                    self.tableView.applyChangeset(changes)
                    print("self.tableView.applyChangeset(changes)")
                } else {
                    self.tableView.reloadData()
                    print("self.tableView.reloadData()")
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
        var dateString = String()
        // DateFormatter を使用して書式とローカルを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d/yyyy", options: 0, locale: Locale(identifier: "en_US"))
        dateString = dateFormatter.string(from: date)

        dateLabel.text = dateString
        selectedDate = date
    }

}

extension CalenderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = records[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.calenderTableCell.identifier)!
        
        cell.textLabel?.text = record.exercise + String(record.weight)
        cell.textLabel?.textColor = UIColor.lightText

        return cell
    }
}

extension CalenderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        Observable.from([laps[indexPath.row]])
        //            .subscribe(Realm.rx.delete())
        //            .disposed(by: bag)
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
