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
    @IBOutlet weak var barItem: UINavigationItem!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var addButton: UIButton!

    @IBAction func addTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

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

    func setup() {
        let input = NoteViewModelInput(
            slider: slider.rx.value,
            stepper: stepper.rx.value,
            selectedDate: selectedDate,
            addButton: addButton.rx.tap,
            pickerTitle: pickerView.rx.modelSelected(String.self),
            pickerIndex: pickerView.rx.itemSelected
        )

        viewModel.setup(input: input)
        bindOutputs()

    }

    func bindOutputs() {

        viewModel.outputs?.secondsDriver
            .drive(timerLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs?.exerciseDataDriver
            .drive(pickerView.rx.itemTitles) { _, title in
                return title
        }
        .disposed(by: disposeBag)

        viewModel.outputs?.weightDriver
            .drive(slider.rx.value)
            .disposed(by: disposeBag)

        viewModel.outputs?.weightStringDriver
            .drive(weightLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs?.repsDriver
            .drive(repsLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs?.dateDriver
            .drive(barItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs?.selectedIndexDriver
            .drive(onNext: { newValue in
                self.pickerView.selectRow(newValue, inComponent: 0, animated: true)
            })
            .disposed(by: disposeBag)

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
