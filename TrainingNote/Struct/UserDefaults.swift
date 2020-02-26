//
//  UserDefault.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/26.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct UserDefault {
    static let userDefault = UserDefaults.standard
    struct Key {
        static let exercise = R.string.userDefaults.exercise()
        static let selectedIndex = R.string.userDefaults.selectedIndex()
        static let weight = R.string.userDefaults.weight()
    }

}

extension UserDefault {
    static var exercises: [String] {
        get { return userDefault.object(forKey: Key.exercise) as? [String] ?? [] }
        set { userDefault.set(newValue, forKey: Key.exercise) }
    }

    static var selectedIndex: Int {
        get { return userDefault.object(forKey: Key.selectedIndex) as? Int ?? 0 }
        set { userDefault.set(newValue, forKey: Key.selectedIndex) }
    }

    static var weight: Float {
        get { return userDefault.object(forKey: Key.weight) as? Float ?? 100 }
        set { userDefault.set(newValue, forKey: Key.weight) }
    }

}
