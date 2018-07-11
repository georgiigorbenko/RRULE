//
//  Date+Comparison.swift
//  RRuleSwift-iOS
//
//  Created by 1amageek on 2018/07/11.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

internal extension Date {
    internal func isBefore(_ date: Date) -> Bool {
        return compare(date) == .orderedAscending
    }

    internal func isSame(with date: Date) -> Bool {
        return compare(date) == .orderedSame
    }

    internal func isAfter(_ date: Date) -> Bool {
        return compare(date) == .orderedDescending
    }

    internal func isBeforeOrSame(with date: Date) -> Bool {
        return isBefore(date) || isSame(with: date)
    }

    internal func isAfterOrSame(with date: Date) -> Bool {
        return isAfter(date) || isSame(with: date)
    }
}
