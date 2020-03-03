//
//  CalenderViewModel.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/02/28.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

struct CalenderViewModelInput {
    let selectedDateRelay: BehaviorRelay<Date>
    let checkDateRelay: PublishRelay<Date>
}

protocol CalenderViewModelOutput {
    var dateStringDriver: Driver<String> {get}
    var eventCountDriver: Driver<Int> {get}
    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {get}
}

protocol CalenderViewModelType {
    var outputs: CalenderViewModelOutput? { get }
    func setup(input: CalenderViewModelInput)
}

final class CalenderViewModel: Injectable, CalenderViewModelType {
    typealias Dependency = CalenderModel
    private let model: CalenderModel

    var outputs: CalenderViewModelOutput?
    private let dateStringRelay = BehaviorRelay<String>(value: "")
    private var eventDateStringArray: [String] = [""]
    private let eventRelay = BehaviorRelay<Int>(value: 0)
    private let formatter = DateStringFormatter()
    private let disposeBag = DisposeBag()
    private var records: Results<Record>!

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: CalenderViewModelInput) {

        input.selectedDateRelay
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                self.dateStringRelay.accept(self.dateToString(date: date))

                //                print(self.getSelectedDateRecords(date: date))
            })
            .disposed(by: disposeBag)

        input.checkDateRelay
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                let checkDateString = self.dateToString(date: date)

                if self.eventDateStringArray.contains(checkDateString) {
                    self.eventRelay.accept(1)
                } else {
                    self.eventRelay.accept(0)
                }
            })
            .disposed(by: disposeBag)

        let modelInput = CalenderModelInput(
            selectedDateRelay: input.selectedDateRelay
        )

        model.setup(input: modelInput)

        model.outputs?.recordsObservable
            .subscribe(onNext: { [weak self] records in
                guard let self = self else { return }

                self.records = records

                var eventDateStringArray: [String] = []
                eventDateStringArray =  records.map {
                    self.formatter.formatt(date: $0.selectedDate)
                }
                self.eventDateStringArray = eventDateStringArray
            })
            .disposed(by: disposeBag)

        model.selectedRecordsObservable.subscribe(onNext: { [weak self] records in
            print("collectionssssssss:   ", records)
        }).disposed(by: disposeBag)

    }

}

extension CalenderViewModel {
    private func dateToString(date: Date) -> String {
        var dateString = String()
        let formatter = DateStringFormatter()
        dateString = formatter.formatt(date: date)
        return dateString
    }
}

extension CalenderViewModel: CalenderViewModelOutput {
    var dateStringDriver: Driver<String> {
        return dateStringRelay.asDriver()
    }

    var eventCountDriver: Driver<Int> {
        return eventRelay.asDriver()
    }

    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {
        return  model.outputs!.recordsChangeObservable
    }

}
