//
//  NoteViewModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/21.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation

struct NoteViewModelInput {
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
}

protocol NoteViewModelOutput {
    //    var exerciseObservable: Observable<[String]?> {get}
}

protocol NoteViewModelType {
    var outputs: NoteViewModelOutput? { get }
    func setupModel(input: NoteViewModelInput)
}

final class NoteViewModel: Injectable, NoteViewModelType {
    typealias Dependency = NoteModel

    private var model: NoteModel
    var outputs: NoteViewModelOutput?

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setupModel(input: NoteViewModelInput) {
        return
    }

}

extension NoteViewModel: NoteViewModelOutput {
    //    var exerciseObservable: Observable<[String]?> {
    //        return UserDefault.userDefault.rx
    //            .observe(Array<String>.self, UserDefault.Key.exercise)
    //    }
}
