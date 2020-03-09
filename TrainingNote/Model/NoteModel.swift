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
import RealmSwift
import RxRealm

struct NoteModelInput {
    let selectedIndex: BehaviorRelay<Int>
    let weightRelay: BehaviorRelay<Float>
    let repsRelay: BehaviorRelay<Double>
    let selectedDateRelay: BehaviorRelay<Date>
    let pickerTitle: BehaviorRelay<String>
    let addButton: ControlEvent<Void>
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
    private var recordDate: Date?
    private var recordExercise: String?
    private var recordWeight: Float?
    private var recordReps: Double?

    var outputs: NoteModelOutput?

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: NoteModelInput) {

        let realm = self.createRealm()

        input.selectedDateRelay
            .subscribe(onNext: { date in
                self.recordDate = date
            })
            .disposed(by: disposeBag)

        input.pickerTitle
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { exercise in
                self.recordExercise = exercise
            })
            .disposed(by: disposeBag)

        input.selectedIndex
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { selectedIndex in
                UserDefault.selectedIndex = selectedIndex
            })
            .disposed(by: disposeBag)

        input.weightRelay
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { weight in
                UserDefault.weight = weight
                self.recordWeight = weight
            })
            .disposed(by: disposeBag)

        input.repsRelay
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { reps in
                self.recordReps = reps
            })
            .disposed(by: disposeBag)

        input.addButton
            .map { self.makeRecord() }
            .bind(to: realm.rx.add(onError: { elements, error in
                if let elements = elements {
                    print("Error \(error.localizedDescription) while saving objects \(String(describing: elements))")
                } else {
                    print("Error \(error.localizedDescription) while opening realm.")
                }
            }))
            .disposed(by: disposeBag)

    }

    private func makeRecord() -> Record {
        let record = Record()
        record.selectedDate = recordDate!
        record.exercise = recordExercise!
        record.weight = recordWeight!
        record.reps = recordReps!
        return record
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

extension NoteModel {
    private func createRealm() -> Realm {
        do {
            return try Realm()
        } catch let error as NSError {
            assertionFailure("realm error: \(error)")
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            // swiftlint:disable:next force_try
            return try! Realm(configuration: config)
            // swiftlint:disable:previous force_try
        }
    }
}
