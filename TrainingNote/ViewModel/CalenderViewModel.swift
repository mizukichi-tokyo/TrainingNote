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

struct CalenderViewModelInput {
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
    let selectedDateRelay: BehaviorRelay<Date>
}

protocol CalenderViewModelOutput {
    var dateStringDriver: Driver<String> {get}
}

protocol CalenderViewModelType {
    var outputs: CalenderViewModelOutput? { get }
    func setup(input: CalenderViewModelInput)
}

final class CalenderViewModel: Injectable, CalenderViewModelType {
    typealias Dependency = CalenderModel
    private let model: CalenderModel

    var outputs: CalenderViewModelOutput?
    private let dataStringRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: CalenderViewModelInput) {

        input.selectedDateRelay.subscribe(onNext: { [weak self] date in
            guard let self = self else { return }
            self.acceptDate(date: date)
        })
            .disposed(by: disposeBag)

        let modelInput = CalenderModelInput(
            selectedDateRelay: input.selectedDateRelay
        )

        model.setup(input: modelInput)

    }

    private func acceptDate(date: Date) {

        var dateString = String()
        let formatter = DateStringFormatter()
        dateString = formatter.formatt(date: date)

        dataStringRelay.accept(dateString)
    }

}

extension CalenderViewModel: CalenderViewModelOutput {

    var dateStringDriver: Driver<String> {
        return self.dataStringRelay.asDriver()
    }

}
