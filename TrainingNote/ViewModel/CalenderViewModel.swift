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
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        model = dependency
        self.outputs = self
    }

    func setup(input: CalenderViewModelInput) {

    }

}

extension CalenderViewModel: CalenderViewModelOutput {

    var dateStringDriver: Driver<String> {
        let dataRelay = BehaviorRelay<String>(value: "")

        let date = Date()
        var dateString = String()

        let formatter = DateStringFormatter()
        dateString = formatter.formatt(date: date)

        dataRelay.accept(dateString)
        return dataRelay.asDriver()
    }

}
