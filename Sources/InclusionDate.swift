//
//  InclusionDate.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public struct InclusionDate {

    /// All inclusive dates.
    public fileprivate(set) var dates: [Date] = []

    public init(dates: [Date]) {
        self.dates = dates
    }

    public init?(rdateString string: String) {
        let string: String = string.trimmingCharacters(in: .whitespaces)
        guard let range: Range = string.range(of: "RDATE:"), range.lowerBound == string.startIndex else {
            return nil
        }
        let rdateString: String = String(string.suffix(from: range.upperBound))
        let rdates: [String] = rdateString.components(separatedBy: ",").compactMap { (dateString) -> String? in

            if dateString.isEmpty {
                return nil
            }

            return dateString
        }

        self.dates = rdates.compactMap({ (dateString) -> Date? in

            if let date: Date = RRule.dateFormatter.date(from: dateString) {
                return date
            } else if let date: Date = RRule.realDate(dateString) {
                return date
            }

            return nil
        })
    }

    public func toRDateString() -> String {
        var rdateString: String = "RDATE:"
        let dateStrings: [String] = dates.map { (date) -> String in
            return RRule.dateFormatter.string(from: date)
        }

        if !dateStrings.isEmpty {
            rdateString += dateStrings.joined(separator: ",")
        }

        if String(rdateString.suffix(from: rdateString.index(rdateString.endIndex, offsetBy: -1))) == "," {
            rdateString.remove(at: rdateString.index(rdateString.endIndex, offsetBy: -1))
        }

        return rdateString
    }
}
