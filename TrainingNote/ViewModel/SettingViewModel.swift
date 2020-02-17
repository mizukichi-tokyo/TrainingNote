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

    init(with dependency: Dependency) {
        updataItems()
        setRequestDeleteRecordStream()
    }

    func setSectionModels() {
        guard let userDefaultsExercises = UserDefaults.standard.array(forKey: UserDefaults.Key.exercise.rawValue) as? [String] else { return }

        var items: [ExerciseData] = []
        for exercise in userDefaultsExercises {
            items.append(ExerciseData(exerciseName: exercise))
        }
        sectionModels = [
            SectionOfExerciseData(items: items)
        ]
    }

    func updataItems() {
        setSectionModels()
        dataRelay.accept(sectionModels)
        //driver Using
        dataDriver = dataRelay.asDriver()
    }

    func setRequestDeleteRecordStream() {
        requestDeleteRecordStream
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }

                guard var userDefaultsExercises = UserDefaults.standard.array(forKey: UserDefaults.Key.exercise.rawValue) as? [String] else { return }
                
                userDefaultsExercises.remove(at: indexPath.row)
                UserDefaults.standard.set(userDefaultsExercises, forKey: UserDefaults.Key.exercise.rawValue)

                strongSelf.updataItems()
            })
            .disposed(by: disposeBag)
    }

}
