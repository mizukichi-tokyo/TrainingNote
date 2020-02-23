//
//  SettingViewModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/15.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

struct SettingViewModelInput {
    let swipeCell: ControlEvent<IndexPath>
    let addItemTextRelay: PublishRelay<String>
}

protocol SettingViewModelOutput {
    var sectionDataDriver: Driver<[SectionOfExerciseData]> { get }
}

protocol SettingViewModelType {
    var outputs: SettingViewModelOutput? { get }
    func setup(input: SettingViewModelInput)
}

final class SettingViewModel: Injectable, SettingViewModelType {
    typealias Dependency = SettingModel

    private var model: SettingModel
    var outputs: SettingViewModelOutput?
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: SettingViewModelInput) {
        let modelInput = SettingModelInput(
            swipeCell: input.swipeCell,
            addItemTextRelay: input.addItemTextRelay
        )
        model.setup(input: modelInput)
    }

}

extension SettingViewModel: SettingViewModelOutput {

    var sectionDataDriver: Driver<[SectionOfExerciseData]> {

        let dataRelay = BehaviorRelay<[SectionOfExerciseData]>(value: [])

        model.outputs?.exerciseObservable
            .subscribe(onNext: { [weak self] exercises in
                guard let self = self, let exercises = exercises else { return }
                let sectionModel = self.makeSectionModels(exercises: exercises)

                dataRelay.accept(sectionModel)
            })
            .disposed(by: disposeBag)

        return dataRelay.asDriver()
    }

    private func makeSectionModels(exercises: [String]) -> [SectionOfExerciseData] {
        var items: [ExerciseData] = []

        for exercise in exercises {
            items.append(ExerciseData(exerciseName: exercise))
        }
        let sectionModels: [SectionOfExerciseData] = [SectionOfExerciseData(items: items)]

        return sectionModels
    }

}
