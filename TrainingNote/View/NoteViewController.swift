//
//  NoteViewController.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NoteViewController: UIViewController, Injectable {
    typealias Dependency = NoteViewModel

    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func moveToCalender(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private let viewModel: NoteViewModel
    private let disposeBag = DisposeBag()
    var selectedDate: Date?

    required init(with dependency: Dependency) {
        viewModel = dependency
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

extension NoteViewController {
    static func makeVC () -> NoteViewController {
        let model = NoteModel(with: NoteModel.Dependency.init())
        let viewModel = NoteViewModel(with: model)
        let viewControler = NoteViewController(with: viewModel)
        return viewControler
    }
}

extension NoteViewController {
    func setup() {
        //        let input = Input(
        //            swipeCell: tableView.rx.itemDeleted,
        //ボタンをタッチされたことを伝えるストリームを流す
        //ボタンをタッチされた時のデータを伝えるストリームを流す
        //        )=
        //        viewModel.setupViewModel(input: input)

        viewModel.outputs?.exerciseDataRelay
            .bind(to: pickerView.rx.itemTitles) { _, title in
                return title
        }
        .disposed(by: disposeBag)

    }
}
//以下　pickerの使用例
//let number = 2
//
//Observable.just(number)
//    .subscribe(onNext: { newValue in
//        // 値が設定されたときの処理
//        self.pickerView.selectRow(newValue, inComponent: 0, animated: true)
//    })
//    .disposed(by: disposeBag)
//
