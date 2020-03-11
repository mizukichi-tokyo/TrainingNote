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
    let swipeCell: ControlEvent<IndexPath>
}

protocol CalenderViewModelOutput {
    var dateStringDriver: Driver<String> {get}
    var eventCountDriver: Driver<Int> {get}
    var recordsChangeObservable: Observable<(AnyRealmCollection<Record>, RealmChangeset?)> {get}
    var selectedRecordsObservable: Observable<Results<Record>?> {get}
    var labelDriver: Driver<[[String]]> {get}
}

protocol CalenderViewModelType {
    var outputs: CalenderViewModelOutput? { get }
    func setup(input: CalenderViewModelInput)
}

final class CalenderViewModel: Injectable, CalenderViewModelType {
    typealias Dependency = CalenderModelType
    private let model: CalenderModelType

    var outputs: CalenderViewModelOutput?
    private let dateStringRelay = BehaviorRelay<String>(value: "")
    private var eventDateStringArray: [String] = [""]
    private let eventRelay = BehaviorRelay<Int>(value: 0)
    private let formatter = DateStringFormatter()
    private let disposeBag = DisposeBag()
    private var records: Results<Record>!
    private var combineRecordsAndDate: Observable<Results<Record>?>!
    private let labelRelay = BehaviorRelay<[[String]]>(value: [[]])

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: CalenderViewModelInput) {

        input.selectedDateRelay
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                self.dateStringRelay.accept(self.dateToString(date: date))

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

        let modelInput = CalenderModelInput()
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

        combineRecordsAndDate = Observable.combineLatest(model.outputs!.recordsObservable, input.selectedDateRelay) { [weak self] stringElement, intElement in
            self?.getSelectedDateRecords(records: stringElement, date: intElement)
        }

        combineRecordsAndDate
            .subscribe(onNext: { records in
                self.labelRelay.accept(self.makeLabel(records: records))
            })
            .disposed(by: disposeBag)

        input.swipeCell
            .withLatestFrom(combineRecordsAndDate) { indexPath, records in
                return records![indexPath.row]
        }
        .subscribe(Realm.rx.delete())
        .disposed(by: disposeBag)
    }
}

extension CalenderViewModel {
    private func dateToString(date: Date) -> String {
        var dateString = String()
        let formatter = DateStringFormatter()
        dateString = formatter.formatt(date: date)
        return dateString
    }

    private func getSelectedDateRecords(records: Results<Record>, date: Date) -> Results<Record>? {
        var selectedDateRecords: Results<Record>?
        let predicate = NSPredicate(
            format: "%@ =< selectedDate AND selectedDate < %@",
            getStartAndEndOfDay(date).start as CVarArg,
            getStartAndEndOfDay(date).end as CVarArg
        )
        selectedDateRecords = records.filter(predicate)
        return selectedDateRecords
    }

    private func getStartAndEndOfDay(_ date: Date) -> (start: Date, end: Date) {
        let start = Calendar(identifier: .gregorian).startOfDay(for: date)
        let end = start + 24 * 60 * 60
        return (start, end)
    }

    private func makeLabel(records: Results<Record>? ) ->( [[String]] ) {
        var labelArray = [[String]]()
        for record in records! {
            let textLabelString = String(format: "% 3.0f", record.reps) + " reps  " + String(format: "% 4.0f", round(record.weight)) + " kg"
            labelArray.append([textLabelString, record.exercise])
        }
        return labelArray
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

    var selectedRecordsObservable: Observable<Results<Record>?> {
        return self.combineRecordsAndDate
    }

    var labelDriver: Driver<[[String]]> {
        return labelRelay.asDriver()
    }
}
