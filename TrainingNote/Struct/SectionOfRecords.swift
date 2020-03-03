//
//  SectionOfRecords.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/03/04.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct RecordsData {
    let textLabel: String
    let detailTextLabel: String
}

struct SectionOfRecords {
    var items: [Item]
}

extension SectionOfRecords: SectionModelType {
    typealias Item = RecordsData

    init(original: SectionOfRecords, items: [SectionOfRecords.Item]) {
        self = original
        self.items = items
    }
}
