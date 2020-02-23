//
//  NoteViewModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/21.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct NoteViewModelInput {
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
}

protocol NoteViewModelOutput {
    var exerciseDataRelay: BehaviorRelay<[String]> { get }
}

protocol NoteViewModelType {
    var outputs: NoteViewModelOutput? { get }
    func setup(input: Input)
}

final class NoteViewModel: Injectable, NoteViewModelType {
    typealias Dependency = NoteModel

    private var model: NoteModel
    var outputs: NoteViewModelOutput?
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: Input) {
        return
    }

}

extension NoteViewModel: NoteViewModelOutput {

    var exerciseDataRelay: BehaviorRelay<[String]> {
        let dataRelay = BehaviorRelay<[String]>(value: [])
        model.outputs?.exerciseObservable
            .subscribe(onNext: { exercises in
                guard let exercises = exercises else { return }
                dataRelay.accept(exercises)
            })
            .disposed(by: disposeBag)

        return dataRelay
    }

}
