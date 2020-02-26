//
//  SettingModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/17.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct SettingModelInput {
    let swipeCell: ControlEvent<IndexPath>
    let addItemTextRelay: PublishRelay<String>
}

protocol SettingModelOutput {
    var exerciseObservable: Observable<[String]?> {get}
}

protocol SettingModelType {
    var outputs: SettingModelOutput? { get }
    func setup(input: SettingModelInput)
}

final class SettingModel: Injectable, SettingModelType {
    struct Dependency {}

    var outputs: SettingModelOutput?
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: SettingModelInput) {
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
        var userDefaultsExercises = UserDefault.exercises
        userDefaultsExercises.append(addItemText)
        UserDefault.exercises = userDefaultsExercises
    }

    func remove(at indexPath: IndexPath) {
        var userDefaultsExercises = UserDefault.exercises
        userDefaultsExercises.remove(at: indexPath.row)
        UserDefault.exercises = userDefaultsExercises
    }

}

extension SettingModel: SettingModelOutput {
    var exerciseObservable: Observable<[String]?> {
        return UserDefault.userDefault.rx
            .observe(Array<String>.self, UserDefault.Key.exercise)
    }
}
