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
    @IBOutlet weak var plusButton: UIBarButtonItem!

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

    @IBAction func moveToCalender(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerTableViewCell()
        setRxPlusButton()
        setupDataSource()
        bindModels()
    }

}

extension SettingViewController {

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

    private func bindModels() {
        viewModel.dataDriver
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.removeItem(at: indexPath)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Static Methods
extension SettingViewController {

    static func makeVC () -> SettingViewController {
        let viewModel = SettingViewModel(with: SettingViewModel.Dependency.init())
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}

extension SettingViewController {

    func setRxPlusButton() {
        plusButton.rx.tap
            .subscribe { [weak self] _ in
                self?.showAlert()
        }
        .disposed(by: disposeBag)
    }

    func showAlert() {
        var uiTextField = UITextField()

        let alertController = UIAlertController(
            title: R.string.settingView.alertTitle(),
            message: R.string.settingView.alertMessage(),
            preferredStyle: .alert
        )

        let addAction = UIAlertAction(title: R.string.settingView.alertAdd(), style: .default) { _ in
            self.viewModel.addItem(uiTextField: uiTextField)
        }

        let cancelAction = UIAlertAction(title: R.string.settingView.alertCancel(), style: .cancel) { _ in
            return
        }

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { textField in
            uiTextField = textField
            textField.placeholder = R.string.settingView.placeholder()
        }

        present(alertController, animated: true, completion: nil)
    }

}
