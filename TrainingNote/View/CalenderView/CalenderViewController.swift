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
    private let disposeBag = DisposeBag()

    private var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

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
