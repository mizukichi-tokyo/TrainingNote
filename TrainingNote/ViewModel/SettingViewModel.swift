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

protocol CounterViewModelType {
    var outputs: SettingViewModelOutput? { get }
    func setup(input: SettingViewModelInput)
}

final class SettingViewModel: Injectable, CounterViewModelType {
    struct Dependency {
    }

    var outputs: SettingViewModelOutput?

    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: SettingViewModelInput) {
        input.swipeCell.subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            self.remove(at: indexPath)
        })
            .disposed(by: disposeBag)

        input.addItemTextRelay.subscribe(onNext: { [weak self] addItemText in
            guard let self = self else { return }
            self.add(add: addItemText)
        })
            .disposed(by: disposeBag)

    }

    func add(add addItemText: String) {
        var userDefaultsExercises = SettingConfig.exercises
        userDefaultsExercises.append(addItemText)
        SettingConfig.exercises = userDefaultsExercises
    }

    func remove(at indexPath: IndexPath) {
        var userDefaultsExercises = SettingConfig.exercises
        userDefaultsExercises.remove(at: indexPath.row)
        SettingConfig.exercises = userDefaultsExercises
    }

}

extension SettingViewModel: SettingViewModelOutput {

    var sectionDataDriver: Driver<[SectionOfExerciseData]> {
        let dataRelay = BehaviorRelay<[SectionOfExerciseData]>(value: [])

        SettingConfig.userDefault.rx
            .observe(Array<String>.self, SettingConfig.Key.exercise)
            .subscribe(onNext: { [weak self] exercises in
                guard let self = self, let exercises = exercises else { return }
                dataRelay.accept(self.makeSectionModels(exercises: exercises))
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
