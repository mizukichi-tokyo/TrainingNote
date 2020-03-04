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
}

protocol CalenderModelOutput {
    var recordsObservable: Observable<Results<Record>> {get}
    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {get}
    var selectedRecordsObservable: Observable<Results<Record>> {get}
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
    private var selectedDateRecords: Results<Record>!

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: CalenderModelInput) {
        let realm = createRealm()

        records = realm.objects(Record.self).sorted(byKeyPath: "creationTime", ascending: false)

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

extension CalenderModel: CalenderModelOutput {
    var recordsObservable: Observable<Results<Record>> {
        return  Observable.collection(from: records)
    }

    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {
        return  Observable.changeset(from: records)
    }

    var selectedRecordsObservable: Observable<Results<Record>> {
        return  Observable.collection(from: selectedDateRecords)
    }

}
