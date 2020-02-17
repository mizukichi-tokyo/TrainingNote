//
//  SettingModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/17.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
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

final class SettingModel {
    func getUserDefaultsExercises() -> [String] {
        guard let userDefaultsExercises = UserDefaults.standard.array(forKey: UserDefaults.Key.exercise.rawValue) as? [String] else { return [String]() }
        return userDefaultsExercises
    }

    func removeExerciseFromUserDefaults(at indexPath: IndexPath) {
        var userDefaultsExercises = getUserDefaultsExercises()
        userDefaultsExercises.remove(at: indexPath.row)
        UserDefaults.standard.set(userDefaultsExercises, forKey: UserDefaults.Key.exercise.rawValue)
    }

    func addExerciseToUserDefaults(uiTextField: UITextField) {
        var userDefaultsExercises = getUserDefaultsExercises()
        userDefaultsExercises.append(uiTextField.text!)
        UserDefaults.standard.set(userDefaultsExercises, forKey: UserDefaults.Key.exercise.rawValue)
    }
}
