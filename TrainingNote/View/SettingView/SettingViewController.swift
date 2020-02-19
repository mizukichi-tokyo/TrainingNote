//
//  SettingViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SettingViewController: UIViewController, Injectable {
    typealias Dependency = SettingViewModel

    @IBOutlet private weak var tableView: UITableView!

    @IBAction func plusButton() {
        alert(title: "Test", message: "This is a test message.")
            .addAction(title: "Yes")
            .addAction(title: "No", style: .destructive)
            .addTextField {
                $0.placeholder = "placeholder"
        }
        .rx.show()
        .subscribe(onNext: {
            print("button: \($0.buttonTitle)")
            print($0.controller.textFields?.first?.text ?? "")
        })
            .disposed(by: disposeBag)
    }

    @IBAction func moveToCalender(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionOfExerciseData>!
    private let viewModel: SettingViewModel

    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupViewModel()

    }

    func setupViewModel() {

        let input = SettingViewModelInput(
            swipeCell: tableView.rx.itemDeleted
        )

        viewModel.setup(input: input)

        viewModel.outputs?.sectionDataDriver
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}

extension SettingViewController {

    private func setupTableView() {
        registerTableViewCell()
        setupDataSource()
    }

    private func registerTableViewCell() {
        tableView.register(
            SettingTableViewCell.self,
            forCellReuseIdentifier: R.reuseIdentifier.settingTableViewCell.identifier
        )
    }

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfExerciseData>(
            configureCell: { ( _, tableView: UITableView, indexPath: IndexPath, model: ExerciseData
                ) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: R.reuseIdentifier.settingTableViewCell.identifier,
                    for: indexPath
                )
                cell.textLabel?.text = model.exerciseName
                return cell
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })
    }

}

extension SettingViewController {
    static func makeVC () -> SettingViewController {
        let viewModel = SettingViewModel(with: SettingViewModel.Dependency.init())
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}
