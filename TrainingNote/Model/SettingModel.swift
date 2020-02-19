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

struct ExerciseData {
    let exerciseName: String
}

struct SectionOfExerciseData {
    var items: [Item]
}

extension SectionOfExerciseData: SectionModelType {
    typealias Item = ExerciseData

    init(original: SectionOfExerciseData, items: [SectionOfExerciseData.Item]) {
        self = original
        self.items = items
    }
}

struct SettingConfig {
    static let userDefault = UserDefaults.standard

    struct Key {
        static let exercise = "exercise"
    }
}

extension SettingConfig {
    static var exercises: [String] {
        get {
            return userDefault.object(forKey: Key.exercise) as? [String] ?? []
        }
        set {
            userDefault.set(newValue, forKey: Key.exercise)
        }
    }

}
