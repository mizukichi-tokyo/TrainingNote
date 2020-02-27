//
//  RealmModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/27.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RealmSwift

final class Record: Object {
    @objc dynamic var creationTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    @objc dynamic var selectedDate: Date = Date()
    @objc dynamic var exercise: String = ""
    @objc dynamic var weight: Float = 0
    @objc dynamic var reps: Double = 0
}
