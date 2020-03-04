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

    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func moveToSetting(_ sender: Any) {
        calenderToSetting()
    }
    @IBAction func moveToNote(_ sender: Any) {
        calenderToNote()
    }
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private var selectedDate = Date()
    private var numberOfEvents: Int?
    private let selectedDateRelay = BehaviorRelay<Date>(value: Date())
    private let checkDateRelay = PublishRelay<Date>()
    private var selectedDateRecords: Results<Record>?
    private var labelArray = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {

        let input = CalenderViewModelInput(
            selectedDateRelay: selectedDateRelay,
            checkDateRelay: checkDateRelay
        )

        viewModel.setup(input: input)

        tableView.register(
            UINib(nibName: "CalenerTableViewCell", bundle: nil),
            forCellReuseIdentifier: R.reuseIdentifier.customCalenderTableCell.identifier
        )

        viewModel.outputs?.recordsChangeObservable
            .subscribe(onNext: { [unowned self] _ in
                self.calendar.reloadData()
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.outputs?.dateStringDriver
            .drive(dateLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs?.eventCountDriver
            .drive( onNext: { eventCountInt in
                self.numberOfEvents = eventCountInt
            }).disposed(by: disposeBag)

        viewModel.outputs?.selectedRecordsObservable
            .subscribe(onNext: { records in
                self.selectedDateRecords = records
            })
            .disposed(by: disposeBag)

        viewModel.outputs?.labelDriver
            .drive(onNext: { labelArray in
                self.labelArray = labelArray
            })
            .disposed(by: disposeBag)
    }
}

extension CalenderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labelArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.customCalenderTableCell.identifier)!

        guard labelArray.count != 0 else { return cell }

        cell.textLabel?.text = labelArray[indexPath.row][0]
        cell.detailTextLabel?.text = labelArray[indexPath.row][1]

        cell.textLabel?.textColor = UIColor.lightText
        cell.detailTextLabel?.textColor = UIColor.lightText

        return cell
    }
}

extension CalenderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            Observable.from([selectedDateRecords![indexPath.row]])
                .subscribe(Realm.rx.delete())
                .disposed(by: disposeBag)
        }
    }
}

extension CalenderViewController {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        selectedDateRelay.accept(date)
        self.tableView.reloadData()
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        checkDateRelay.accept(date)
        return numberOfEvents!
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
        let model = CalenderModel(with: CalenderModel.Dependency.init())
        let viewModel = CalenderViewModel(with: model)
        let viewControler = CalenderViewController(with: viewModel)
        return viewControler
    }
}
