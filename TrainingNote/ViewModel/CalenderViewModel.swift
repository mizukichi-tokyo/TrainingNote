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
import RxDataSources

struct CalenderViewModelInput {
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
}

protocol CalenderViewModelOutput {
    var dateDriver: Driver<String> {get}
}

protocol CalenderViewModelType {
    var outputs: CalenderViewModelOutput? { get }
    func setup(input: CalenderViewModelInput)
}

final class CalenderViewModel: Injectable, CalenderViewModelType {
    struct Dependency {}

    var outputs: CalenderViewModelOutput?
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: CalenderViewModelInput) {

    }

}

extension CalenderViewModel: CalenderViewModelOutput {

    var dateDriver: Driver<String> {
        let dataRelay = BehaviorRelay<String>(value: "")

        let date = Date()
        var dateString = String()

        let formatter = DateStringFormatter()
        dateString = formatter.formatt(date: date)

        dataRelay.accept(dateString)
        return dataRelay.asDriver()
    }

}
