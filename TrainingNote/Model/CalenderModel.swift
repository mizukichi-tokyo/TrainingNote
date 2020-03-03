//
//  CalenderModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/03/03.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

struct CalenderModelInput {
    let selectedDateRelay: BehaviorRelay<Date>
}

protocol CalenderModelOutput {
    var recordsObservable: Observable<Results<Record>> {get}
}

protocol CalenderModelType {
    var outputs: CalenderModelOutput? { get }
    func setup(input: CalenderModelInput)
}

final class CalenderModel: Injectable, CalenderModelType {
    struct Dependency {}

    var outputs: CalenderModelOutput?
    private var selectedDate: Date?
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: CalenderModelInput) {
        input.selectedDateRelay.subscribe(onNext: { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
        })
            .disposed(by: disposeBag)

    }

}

extension CalenderModel: CalenderModelOutput {
    var recordsObservable: Observable<Results<Record>> {
        let realm = createRealm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        var records: Results<Record>!
        records = realm.objects(Record.self).sorted(byKeyPath: "creationTime", ascending: false)

        return  Observable.collection(from: records)
    }

}

extension CalenderModel {
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
