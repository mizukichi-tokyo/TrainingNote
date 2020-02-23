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
        showAlert( addItemTextRelay: addItemTextRelay )
    }
    @IBAction func moveToCalender(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private let viewModel: SettingViewModel
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionOfExerciseData>!
    private let addItemTextRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()

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
        setup()
    }

    func setup() {

        let input = Input(
            swipeCell: tableView.rx.itemDeleted,
            addItemTextRelay: addItemTextRelay
        )
        viewModel.setup(input: input)

        viewModel.outputs?.sectionDataDriver
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

}

extension SettingViewController {

    func showAlert( addItemTextRelay: PublishRelay<String>) {
        var uiTextField = UITextField()

        let alertController = UIAlertController(
            title: R.string.settingView.empty(),
            message: R.string.settingView.empty(),
            preferredStyle: .alert
        )

        let attributedTitle = NSAttributedString(
            string: R.string.settingView.alertTitle(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        )

        let attributedMessage = NSAttributedString(
            string: R.string.settingView.alertMessage(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText]
        )

        alertController.setValue(attributedTitle, forKey: R.string.settingView.attributedTitle())
        alertController.setValue(attributedMessage, forKey: R.string.settingView.attributedMessage())

        let addAction = UIAlertAction(title: R.string.settingView.alertAdd(), style: .default) { _ in
            addItemTextRelay.accept(uiTextField.text!)
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
                cell.textLabel?.textColor = UIColor.lightText
                return cell
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })
    }

}

extension SettingViewController {
    static func makeVC () -> SettingViewController {
        let model = SettingModel(with: SettingModel.Dependency.init())
        let viewModel = SettingViewModel(with: model)
        let viewControler = SettingViewController(with: viewModel)
        return viewControler
    }
}
