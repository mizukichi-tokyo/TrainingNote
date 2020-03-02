//
//  DateFormatter.swift
//  TrainingNote
//
//  Created by Mizuki Kubota on 2020/03/02.
//  Copyright © 2020 MizukiKubota. All rights reserved.
//

import Foundation

struct DateStringFormatter {
    let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "M/d/yyyy",
            options: 0,
            locale: Locale(identifier: "jp_JP")
        )
    }

    func formatt(date: Date) -> String {
        var dateString: String

        dateString = dateFormatter.string(from: date)

        return dateString
    }
}
