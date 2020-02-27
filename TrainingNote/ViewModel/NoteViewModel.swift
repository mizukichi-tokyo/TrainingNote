//
//  NoteViewModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/21.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct NoteViewModelInput {
    let slider: ControlProperty<Float>
    let stepper: ControlProperty<Double>
    let selectedDate: Date?
    let addButton: ControlEvent<Void>
    let pickerTitle: ControlEvent<[String]>
    let pickerIndex: ControlEvent<(row: Int, component: Int)>
}

protocol NoteViewModelOutput {
    var exerciseDataDriver: Driver<[String]> { get }
    var weightDriver: Driver<Float> { get }
    var weightStringDriver: Driver<String> { get }
    var repsDriver: Driver<String> { get }
    var secondsDriver: Driver<String> { get }
    var dateDriver: Driver<String> { get }
    var selectedIndexDriver: Driver<Int> { get }
}

protocol NoteViewModelType {
    var outputs: NoteViewModelOutput? { get }
    func setup(input: NoteViewModelInput)
}

final class NoteViewModel: Injectable, NoteViewModelType {
    typealias Dependency = NoteModel

    private var model: NoteModel
    var outputs: NoteViewModelOutput?

    private let weightRelay = BehaviorRelay<Float>(value: UserDefault.weight)
    private let repsRelay = BehaviorRelay<Double>(value: 0)
    private var selectedDate: Date?
    private var pickerTitle =  BehaviorRelay<String>(value: "")
    private var selectedIndex = BehaviorRelay<Int>(value: UserDefault.selectedIndex)

    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: NoteViewModelInput) {

        subscribeInputs(input: input)

        setDefaultPicker()
        setDefaultSlider()

        let modelInput = NoteModelInput(
            selectedIndex: selectedIndex,
            weightRelay: weightRelay,
            repsRelay: repsRelay,
            selectedDate: selectedDate,
            pickerTitle: pickerTitle,
            addButton: input.addButton
        )
        model.setup(input: modelInput)

    }

}

extension NoteViewModel {

    private func subscribeInputs(input: NoteViewModelInput) {
        input.slider
            .subscribe(onNext: { [weak self] slider in
                guard let self = self else { return }
                self.weightRelay.accept(slider)
            })
            .disposed(by: disposeBag)

        input.stepper
            .subscribe(onNext: { [weak self] stepper in
                guard let self = self else { return }
                self.repsRelay.accept(stepper)
            })
            .disposed(by: disposeBag)

        selectedDate = input.selectedDate

        input.pickerTitle
            .subscribe(onNext: { [weak self] pickertitle in
                guard let self = self else { return }
                self.pickerTitle.accept(pickertitle[0])
            })
            .disposed(by: disposeBag)

        input.pickerIndex
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                self.selectedIndex.accept(selected.row)
            })
            .disposed(by: disposeBag)

    }

}

extension NoteViewModel {

    private func setDefaultPicker() {
        setDefaultSelectedIndex()
        setDefaultPickerTitle()
    }

    private func setDefaultPickerTitle() {
        setDefaultSelectedIndex()

        model.outputs?.exerciseObservable
            .subscribe(onNext: { [weak self] exercises in
                guard let self = self, let exercises = exercises, exercises != [] else { return }
                let index = self.compareDefaultExerciseCount(index: self.selectedIndex.value)
                self.pickerTitle.accept(exercises[index])
            })
            .disposed(by: disposeBag)
    }

    private func setDefaultSelectedIndex() {
        model.outputs?.selectedIndexObservable
            .subscribe(onNext: { [weak self] index in
                guard let self = self, var index = index else { return }
                index = self.compareDefaultExerciseCount(index: index)
                self.selectedIndex.accept(index)
            })
            .disposed(by: disposeBag)
    }

    private func compareDefaultExerciseCount(index: Int) -> Int {
        var returnIndex: Int = 0
        model.outputs?.exerciseObservable
            .subscribe(onNext: { exercises in
                guard let exercises = exercises else { return }
                if index < exercises.count {
                    returnIndex = index
                }
            })
            .disposed(by: disposeBag)
        return returnIndex
    }

    private func setDefaultSlider() {
        model.outputs?.selectedWeightObservable
            .subscribe(onNext: { [weak self] weight in
                guard let self = self, let weight = weight else { return }
                self.weightRelay.accept(weight)
            })
            .disposed(by: disposeBag)
    }

}

extension NoteViewModel: NoteViewModelOutput {

    var exerciseDataDriver: Driver<[String]> {
        let dataRelay = BehaviorRelay<[String]>(value: [])
        model.outputs?.exerciseObservable
            .subscribe(onNext: { exercises in
                guard let exercises = exercises else { return }
                dataRelay.accept(exercises)
            })
            .disposed(by: disposeBag)

        return dataRelay.asDriver()
    }

    var weightDriver: Driver<Float> {
        return weightRelay.asDriver()
    }

    var weightStringDriver: Driver<String> {
        return weightRelay.asDriver().map {round($0)}.map {"\($0.description) kg"}
    }

    var repsDriver: Driver<String> {
        return repsRelay.asDriver().map {Int($0)}.map {"\($0.description) reps"}
    }

    var secondsDriver: Driver<String> {
        return Observable<Int>
            .interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: 0)
            .map { String(format: "Interval: %02i:%02i:%02i", $0 / 6000, $0 / 100 % 60, $0 % 100) }
    }

    var dateDriver: Driver<String> {
        let dataRelay = BehaviorRelay<String>(value: "")

        let dateFormatter = DateFormatter()
        var dateString = String()
        // DateFormatter を使用して書式とローカルを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "M/d/yyyy", options: 0, locale: Locale(identifier: "en_US"))
        dateString = dateFormatter.string(from: selectedDate!)

        dataRelay.accept(dateString)
        return dataRelay.asDriver()
    }

    var selectedIndexDriver: Driver<Int> {
        return selectedIndex.asDriver()
    }

}
