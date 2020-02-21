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
        fatalError(R.string.settingView.fatalErrorMessage())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

//以下　pickerの使用例
// strsをstrPickerViewのデータ(タイトル)としてバインド
//let strs = ["abc", "def", "ghi"]
//Observable.just(strs)
//    .bind(to: pickerView.rx.itemTitles) { _, str in
//        return str
//}
//.disposed(by: disposeBag)
//
//let number = 2
//
//Observable.just(number)
//    .subscribe(onNext: { newValue in
//        // 値が設定されたときの処理
//        self.pickerView.selectRow(newValue, inComponent: 0, animated: true)
//    })
//    .disposed(by: disposeBag)
//
