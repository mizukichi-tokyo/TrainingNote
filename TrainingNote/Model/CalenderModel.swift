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

struct CalenderModelInput {
    //    let swipeCell: ControlEvent<IndexPath>
    //    let addItemTextRelay: PublishRelay<String>
}

protocol CalenderModelOutput {
    //    var dateDriver: Driver<String> {get}
}

protocol CalenderModelType {
    var outputs: CalenderModelOutput? { get }
    func setup(input: CalenderModelInput)
}

final class CalenderModel: Injectable, CalenderModelType {
    struct Dependency {}

    var outputs: CalenderModelOutput?
    private let disposeBag = DisposeBag()

    init(with dependency: Dependency) {
        self.outputs = self
    }

    func setup(input: CalenderModelInput) {

    }

}

extension CalenderModel: CalenderModelOutput {

    //    var dateDriver: Driver<String> {
    //        let dataRelay = BehaviorRelay<String>(value: "")
    //
    //        let date = Date()
    //        var dateString = String()
    //
    //        let formatter = DateStringFormatter()
    //        dateString = formatter.formatt(date: date)
    //
    //        dataRelay.accept(dateString)
    //        return dataRelay.asDriver()
    //    }

}
