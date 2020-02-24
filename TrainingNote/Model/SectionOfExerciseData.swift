//
//  SectionOfExerciseData.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/20.
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
