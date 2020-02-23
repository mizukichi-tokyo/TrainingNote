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
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
}

protocol NoteModelOutput {
    var exerciseObservable: Observable<[String]?> {get}
}

protocol NoteModelType {
    var outputs: NoteModelOutput? { get }
    func setup(input: Input)
}

final class NoteModel: Injectable, NoteModelType {

    struct Dependency {}
    var outputs: NoteModelOutput?

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: Input) {
        return
    }

}

extension NoteModel: NoteModelOutput {
    var exerciseObservable: Observable<[String]?> {
        return UserDefault.userDefault.rx
            .observe(Array<String>.self, UserDefault.Key.exercise)
    }
}
