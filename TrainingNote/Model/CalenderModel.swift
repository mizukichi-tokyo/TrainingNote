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
    let selectedDateRelay: BehaviorRelay<Date>
}

protocol CalenderModelOutput {
    //        var selectedDateStringRelay: BehaviorRelay<String> {get}
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

    //        var selectedDateStringRelay: BehaviorRelay<String> {
    //
    //            //input.selectedDateRelay に変化があったら、変化してストリングリレーに変換して返す
    //            var dateString = String()
    //
    //            let formatter = DateStringFormatter()
    //            dateString = formatter.formatt(date: self.selectedDate!)
    //
    //            let dataRelay = BehaviorRelay<String>(value: "")
    //            dataRelay.accept(dateString)
    //            return dataRelay
    //        }

}
