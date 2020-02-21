//
//  NoteModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/21.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation

struct NoteModelInput {
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
}

protocol NoteModelOutput {
    //    var exerciseObservable: Observable<[String]?> {get}
}

protocol NoteModelType {
    var outputs: NoteModelOutput? { get }
    func setupModel(input: NoteModelInput)
}

final class NoteModel: Injectable, NoteModelType {

    struct Dependency {}
    var outputs: NoteModelOutput?

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setupModel(input: NoteModelInput) {
        return
    }

}

extension NoteModel: NoteModelOutput {
    //    var exerciseObservable: Observable<[String]?> {
    //        return UserDefault.userDefault.rx
    //            .observe(Array<String>.self, UserDefault.Key.exercise)
    //    }
}
