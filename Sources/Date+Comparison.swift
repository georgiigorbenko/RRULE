//
//  Date+Comparison.swift
//  RRuleSwift-iOS
//
//  Created by 1amageek on 2018/07/11.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

internal extension Date {
    func isBefore(_ date: Date) -> Bool {
        return compare(date) == .orderedAscending
    }

    func isSame(with date: Date) -> Bool {
        return compare(date) == .orderedSame
    }

    func isAfter(_ date: Date) -> Bool {
        return compare(date) == .orderedDescending
    }

    func isBeforeOrSame(with date: Date) -> Bool {
        return isBefore(date) || isSame(with: date)
    }

    func isAfterOrSame(with date: Date) -> Bool {
        return isAfter(date) || isSame(with: date)
    }
}
