//
//  NoteModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/21.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct NoteModelInput {
    let selectedIndex: BehaviorRelay<Int>
    let weightRelay: BehaviorRelay<Float>
}

protocol NoteModelOutput {
    var exerciseObservable: Observable<[String]?> {get}
    var selectedIndexObservable: Observable<Int?> {get}
    var selectedWeightObservable: Observable<Float?> {get}
}

protocol NoteModelType {
    var outputs: NoteModelOutput? { get }
    func setup(input: NoteModelInput)
}

final class NoteModel: Injectable, NoteModelType {
    struct Dependency {}

    private let disposeBag = DisposeBag()
    var outputs: NoteModelOutput?

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: NoteModelInput) {

        input.selectedIndex.subscribe(onNext: { selectedIndex in
            UserDefault.selectedIndex = selectedIndex
        })
            .disposed(by: disposeBag)

        input.weightRelay.subscribe(onNext: { weight in
            UserDefault.weight = weight
        })
            .disposed(by: disposeBag)

    }
}

extension NoteModel: NoteModelOutput {
    var exerciseObservable: Observable<[String]?> {
        return UserDefault.userDefault.rx
            .observe(Array<String>.self, UserDefault.Key.exercise)
    }

    var selectedIndexObservable: Observable<Int?> {
        return UserDefault.userDefault.rx
            .observe(Int.self, UserDefault.Key.selectedIndex)
    }

    var selectedWeightObservable: Observable<Float?> {
        return UserDefault.userDefault.rx
            .observe(Float.self, UserDefault.Key.weight)
    }

}
