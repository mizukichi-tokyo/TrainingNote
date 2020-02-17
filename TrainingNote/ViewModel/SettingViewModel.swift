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

final class SettingViewModel: Injectable {
    struct Dependency {
    }

    private let disposeBag = DisposeBag()
    private var sectionModels: [SectionOfExerciseData]!
    let requestDeleteRecordStream = PublishRelay<IndexPath>()
    var dataRelay = BehaviorRelay<[SectionOfExerciseData]>(value: [])
    var dataDriver: Driver<[SectionOfExerciseData]> = Driver.never()
    let model = SettingModel()

    init(with dependency: Dependency) {
        updataItems()
    }

    func updataItems() {
        dataRelay.accept(makeSectionModels())
        dataDriver = dataRelay.asDriver()
    }

    func removeItem(at indexPath: IndexPath) {
        model.removeExerciseFromUserDefaults(at: indexPath)
        self.updataItems()
    }

    func addItem(uiTextField: UITextField) {
        model.addExerciseToUserDefaults(uiTextField: uiTextField)
        self.updataItems()
    }

    func makeSectionModels() -> [SectionOfExerciseData] {

        let userDefaultsExercises: [String] = model.getUserDefaultsExercises()
        var items: [ExerciseData] = []
        for exercise in userDefaultsExercises {
            items.append(ExerciseData(exerciseName: exercise))
        }
        let sectionModels: [SectionOfExerciseData] = [SectionOfExerciseData(items: items)]
        return sectionModels
    }

}
