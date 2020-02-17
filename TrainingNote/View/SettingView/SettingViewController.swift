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

    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionOfExerciseData>!
    private let viewModel: SettingViewModel

    // 初期化時にViewModelを設定できるようにする
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

        // Do any additional setup after loading the view.
        tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: R.reuseIdentifier.settingTableViewCell.identifier)
        setupDataSource()
        bindModels()
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }

                // ViewModelにテーブルビューの行を削除操作を伝える
                Observable.just(indexPath)
                    .bind(to: strongSelf.viewModel.requestDeleteRecordStream)
                    .disposed(by: strongSelf.disposeBag)
            })
            .disposed(by: disposeBag)
    }

}

extension SettingViewController {

    private func setupDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfExerciseData>(
            configureCell: { ( _, tableView: UITableView, indexPath: IndexPath, model: ExerciseData
                ) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingTableViewCell.identifier, for: indexPath)
                cell.textLabel?.text = model.exerciseName
                return cell
        }, canEditRowAtIndexPath: { _, _ in
            return true
        })
    }

    private func bindModels() {
        //        viewModel.dataRelay
        //            .bind(to: tableView.rx.items(dataSource: dataSource))
        //            .disposed(by: disposeBag)

        //using Driver
        viewModel.dataDriver
            .drive(tableView.rx.items(dataSource: dataSource))
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
