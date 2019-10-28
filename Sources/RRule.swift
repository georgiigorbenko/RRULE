//
//  RRule.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/28.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import EventKit
import Foundation

public struct RRule {

    public static let dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateFormatter
    }()

    public static let ymdDateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()

    internal static let ISO8601DateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()

    public static func ruleFromString(_ string: String) -> RecurrenceRule? {
        let string: String = string.trimmingCharacters(in: .whitespaces)
        guard let range: Range = string.range(of: "RRULE:"), range.lowerBound == string.startIndex else {
            return nil
        }
        let ruleString: String = String(string.suffix(from: range.upperBound))
        let rules: [String] = ruleString.components(separatedBy: ";").compactMap { (rule) -> String? in
            if rule.isEmpty {
                return nil
            }
            return rule
        }

        var recurrenceRule: RecurrenceRule = RecurrenceRule(frequency: .daily)
        var ruleFrequency: RecurrenceFrequency?
        for rule: String in rules {
            let ruleComponents: [String] = rule.components(separatedBy: "=")
            guard ruleComponents.count == 2 else {
                continue
            }
            let ruleName: String = ruleComponents[0]
            let ruleValue: String = ruleComponents[1]
            guard !ruleValue.isEmpty else {
                continue
            }

            if ruleName == "FREQ" {
                ruleFrequency = RecurrenceFrequency.frequency(from: ruleValue)
            }

            if ruleName == "INTERVAL" {
                if let interval: Int = Int(ruleValue) {
                    recurrenceRule.interval = max(1, interval)
                }
            }

            if ruleName == "WKST" {
                if let firstDayOfWeek: EKWeekday = EKWeekday.weekdayFromSymbol(ruleValue) {
                    recurrenceRule.firstDayOfWeek = firstDayOfWeek
                }
            }

            if ruleName == "UNTIL" {
                if let endDate: Date = dateFormatter.date(from: ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endDate)
                } else if let endDate: Date = realDate(ruleValue) {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(end: endDate)
                }
            } else if ruleName == "COUNT" {
                if let count: Int = Int(ruleValue), count != 0 {
                    recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: count)
                }
            }

            if ruleName == "BYSETPOS" {
                let bysetpos: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    guard let setpo: Int = Int(string), (-366...366 ~= setpo) && (setpo != 0) else {
                        return nil
                    }
                    return setpo
                }
                recurrenceRule.bysetpos = bysetpos.sorted(by: <)
            }

            if ruleName == "BYYEARDAY" {
                let byyearday: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    guard let yearday: Int = Int(string), (-366...366 ~= yearday) && (yearday != 0) else {
                        return nil
                    }
                    return yearday
                }
                recurrenceRule.byyearday = byyearday.sorted(by: <)
            }

            if ruleName == "BYMONTH" {
                let bymonth: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    guard let month: Int = Int(string), 1...12 ~= month else {
                        return nil
                    }
                    return month
                }
                recurrenceRule.bymonth = bymonth.sorted(by: <)
            }

            if ruleName == "BYWEEKNO" {
                let byweekno: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    guard let weekno: Int = Int(string), (-53...53 ~= weekno) && (weekno != 0) else {
                        return nil
                    }
                    return weekno
                }
                recurrenceRule.byweekno = byweekno.sorted(by: <)
            }

            if ruleName == "BYMONTHDAY" {
                let bymonthday: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    guard let monthday: Int = Int(string), (-31...31 ~= monthday) && (monthday != 0) else {
                        return nil
                    }
                    return monthday
                }
                recurrenceRule.bymonthday = bymonthday.sorted(by: <)
            }

            if ruleName == "BYDAY" {
                // These variables will define the weekdays where the recurrence will be applied.
                // In the RFC documentation, it is specified as BYDAY, but was renamed to avoid the ambiguity of that argument.
                let byweekday: [EKWeekday] = ruleValue.components(separatedBy: ",").compactMap { (string) -> EKWeekday? in
                    return EKWeekday.weekdayFromSymbol(string)
                }
                recurrenceRule.byweekday = byweekday.sorted(by: <)
            }

            if ruleName == "BYHOUR" {
                let byhour: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    return Int(string)
                }
                recurrenceRule.byhour = byhour.sorted(by: <)
            }

            if ruleName == "BYMINUTE" {
                let byminute: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    return Int(string)
                }
                recurrenceRule.byminute = byminute.sorted(by: <)
            }

            if ruleName == "BYSECOND" {
                let bysecond: [Int] = ruleValue.components(separatedBy: ",").compactMap { (string) -> Int? in
                    return Int(string)
                }
                recurrenceRule.bysecond = bysecond.sorted(by: <)
            }
        }

        guard let frequency: RecurrenceFrequency = ruleFrequency else {
            print("error: invalid frequency")
            return nil
        }
        recurrenceRule.frequency = frequency
        return recurrenceRule
    }

    public static func stringFromRule(_ rule: RecurrenceRule) -> String {

        var rruleString: String = "RRULE:"

        rruleString += "FREQ=\(rule.frequency.toString());"

        let interval: Int = max(1, rule.interval)
        rruleString += "INTERVAL=\(interval);"

        rruleString += "WKST=\(rule.firstDayOfWeek.toSymbol());"

        if let endDate: Date = rule.recurrenceEnd?.endDate {
            rruleString += "UNTIL=\(dateFormatter.string(from: endDate));"
        } else if let count: Int = rule.recurrenceEnd?.occurrenceCount {
            rruleString += "COUNT=\(count);"
        }

        let bysetposStrings: [String] = rule.bysetpos.compactMap { (setpo) -> String? in
            guard (-366...366 ~= setpo) && (setpo != 0) else { return nil }
            return String(setpo)
        }

        if !bysetposStrings.isEmpty {
            rruleString += "BYSETPOS=\(bysetposStrings.joined(separator: ","));"
        }

        let byyeardayStrings: [String] = rule.byyearday.compactMap { (yearday) -> String? in
            guard (-366...366 ~= yearday) && (yearday != 0) else { return nil }
            return String(yearday)
        }

        if !byyeardayStrings.isEmpty {
            rruleString += "BYYEARDAY=\(byyeardayStrings.joined(separator: ","));"
        }

        let bymonthStrings: [String] = rule.bymonth.compactMap { (month) -> String? in
            guard 1...12 ~= month else { return nil }
            return String(month)
        }

        if !bymonthStrings.isEmpty {
            rruleString += "BYMONTH=\(bymonthStrings.joined(separator: ","));"
        }

        let byweeknoStrings: [String] = rule.byweekno.compactMap { (weekno) -> String? in
            guard (-53...53 ~= weekno) && (weekno != 0) else { return nil }
            return String(weekno)
        }

        if !byweeknoStrings.isEmpty {
            rruleString += "BYWEEKNO=\(byweeknoStrings.joined(separator: ","));"
        }

        let bymonthdayStrings: [String] = rule.bymonthday.compactMap { (monthday) -> String? in
            guard (-31...31 ~= monthday) && (monthday != 0) else { return nil }
            return String(monthday)
        }

        if !bymonthdayStrings.isEmpty {
            rruleString += "BYMONTHDAY=\(bymonthdayStrings.joined(separator: ","));"
        }

        let byweekdaySymbols: [String] = rule.byweekday.map { (weekday) -> String in
            return weekday.toSymbol()
        }

        if !byweekdaySymbols.isEmpty {
            rruleString += "BYDAY=\(byweekdaySymbols.joined(separator: ","));"
        }

        let byhourStrings: [String] = rule.byhour.map { (hour) -> String in
            return String(hour)
        }

        if !byhourStrings.isEmpty {
            rruleString += "BYHOUR=\(byhourStrings.joined(separator: ","));"
        }

        let byminuteStrings: [String] = rule.byminute.map { (minute) -> String in
            return String(minute)
        }

        if !byminuteStrings.isEmpty {
            rruleString += "BYMINUTE=\(byminuteStrings.joined(separator: ","));"
        }

        let bysecondStrings: [String] = rule.bysecond.map { (second) -> String in
            return String(second)
        }

        if !bysecondStrings.isEmpty {
            rruleString += "BYSECOND=\(bysecondStrings.joined(separator: ","));"
        }

        if String(rruleString.suffix(from: rruleString.index(rruleString.endIndex, offsetBy: -1))) == ";" {
            rruleString.remove(at: rruleString.index(rruleString.endIndex, offsetBy: -1))
        }

        return rruleString
    }

    static func realDate(_ dateString: String?) -> Date? {
        guard let dateString: String = dateString else { return nil }
        guard let date: Date = ymdDateFormatter.date(from: dateString) else { return nil }
        let destinationTimeZone: TimeZone = NSTimeZone.local
        let sourceGMTOffset: Int = destinationTimeZone.secondsFromGMT(for: Date())
        let timeInterval: TimeInterval = date.timeIntervalSince1970
        let realOffset: TimeInterval = timeInterval - TimeInterval(sourceGMTOffset)
        let realDate: Date = Date(timeIntervalSince1970: realOffset)
        return realDate
    }
}
