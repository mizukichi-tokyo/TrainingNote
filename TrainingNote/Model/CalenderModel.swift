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
    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {get}
}

protocol CalenderModelType {
    var outputs: CalenderModelOutput? {get}
    func setup(input: CalenderModelInput)
}

final class CalenderModel: Injectable, CalenderModelType {
    struct Dependency {}

    var outputs: CalenderModelOutput?
    private let disposeBag = DisposeBag()
    private var records: Results<Record>!
    private var selectedDateRecords: Results<Record>?

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: CalenderModelInput) {
        let realm = createRealm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        records = realm.objects(Record.self).sorted(byKeyPath: "creationTime", ascending: false)

        input.selectedDateRelay.subscribe(onNext: { [weak self] date in
            guard let self = self else { return }
            self.selectedDateRecords = self.getSelectedDateRecords(realm: realm, date: date)
        })
            .disposed(by: disposeBag)

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

    private func getSelectedDateRecords(realm: Realm, date: Date) -> Results<Record>? {
        var selectedDateRecords: Results<Record>?

        let predicate = NSPredicate(
            format: "%@ =< selectedDate AND selectedDate < %@",
            getStartAndEndOfDay(date).start as CVarArg,
            getStartAndEndOfDay(date).end as CVarArg
        )

        selectedDateRecords = realm.objects(Record.self).filter(predicate).sorted(byKeyPath: "creationTime", ascending: false)
        return selectedDateRecords
    }

    private func getStartAndEndOfDay(_ date: Date) -> (start: Date, end: Date) {
        let start = Calendar(identifier: .gregorian).startOfDay(for: date)
        let end = start + 24 * 60 * 60
        return (start, end)
    }
}

extension CalenderModel: CalenderModelOutput {
    var recordsObservable: Observable<Results<Record>> {
        return  Observable.collection(from: records)
    }

    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {
        return  Observable.changeset(from: records)
    }

}
