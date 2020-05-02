//
//  Date+CheckSameDay.swift
//  com.commemoratemessenger
//
//  Created by Tomas Cejka on 4/14/20.
//  Copyright © 2020 CJ. All rights reserved.
//

import Foundation

extension Date {
    func isInSameDayOf(date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs:date)
    }
}
